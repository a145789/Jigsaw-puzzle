%%raw(`import './App.css'`)

@module("react")
external useTransition: unit => (bool, (. unit => unit) => unit) = "useTransition"

@val @scope("window")
external alert: string => unit = "alert"

type appMode = Manual | Auto | Over

type rec autoNode = {
  currentStatus: array<array<int>>,
  parent: option<autoNode>,
  id: string,
  score: int,
  step: int,
  position: (int, int),
}

type originSet<'a> = {
  add: (. 'a) => unit,
  has: (. 'a) => bool,
}

let endArr = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

@react.component
let make = () => {
  let (step, setStep) = React.useState(() => 0)
  let (time, setTime) = React.useState(() => 0)
  let (jigsawArray: array<array<int>>, setJigsawArray) = React.useState(() => [])
  let (_isPending, startTransition) = useTransition()
  let (isPending, setIsPending) = React.useState(() => false)
  let (mode: appMode, setMode) = React.useState(() => Manual)

  let emtyPosition = React.useRef((2, 2))
  let path: React.ref<array<(int, int)>> = React.useRef([])
  let pathIdx = React.useRef(0)
  let jigsawArrayRef = React.useRef(jigsawArray)

  let isUnsolvable = arr => {
    let a = ref(0)
    Belt.Array.forEachWithIndex(arr, (index, item) => {
      for i in index + 1 to Belt.Array.length(arr) - 1 {
        if item > arr[i] {
          a := a.contents + 1
        }
      }
    })
    mod(a.contents, 2) !== 0
  }

  let rec genJigsaw = () => {
    let result =
      [1, 2, 3, 4, 5, 6, 7, 8]->Js.Array2.sortInPlaceWith((_, _) => Js.Math.random() > 0.5 ? 1 : -1)
    if isUnsolvable(result) {
      genJigsaw()
    } else {
      result
    }
  }

  let genId = (arr: array<array<int>>) => {
    arr->Belt_Array.concatMany->Belt_Array.joinWith("", n => n->Belt.Int.toString)
  }

  let getDeepCloneJigsawArray = (arr: array<array<int>>) => arr->Belt.Array.map(Belt.Array.copy)

  let virtualConvert = (
    (nextY, nextX): (int, int),
    (emptyY, emptyX): (int, int),
    arr: array<array<int>>,
  ) => {
    let jigsawArrayCopy = getDeepCloneJigsawArray(arr)

    let replaceValue = jigsawArrayCopy[nextY][nextX]
    jigsawArrayCopy[nextY][nextX] = 9
    jigsawArrayCopy[emptyY][emptyX] = replaceValue

    jigsawArrayCopy
  }

  let tearArr = (arr: array<int>) => {
    [
      Js.Array2.slice(arr, ~start=0, ~end_=3),
      Js.Array2.slice(arr, ~start=3, ~end_=6),
      Js.Array2.slice(arr, ~start=6, ~end_=9),
    ]
  }

  let isEnd = (id: string) => {
    id === "123456789"
  }

  let restGame = () => {
    setStep(_ => 0)
    setTime(_ => 0)
    emtyPosition.current = (2, 2)
    jigsawArrayRef.current = []
    setJigsawArray(_ => jigsawArrayRef.current)
    path.current = []
    pathIdx.current = 0
  }

  let beginInit = () => {
    restGame()
    jigsawArrayRef.current = genJigsaw()->Belt.Array.concat([9])->tearArr
    setJigsawArray(_ => jigsawArrayRef.current)
  }

  let squareRun = ((nextY, nextX): (int, int)) => {
    jigsawArrayRef.current = virtualConvert(
      (nextY, nextX),
      emtyPosition.current,
      jigsawArrayRef.current,
    )
    setJigsawArray(_ => jigsawArrayRef.current)
    setStep(_ => step + 1)
    emtyPosition.current = (nextY, nextX)
  }

  let manualGame = () => {
    setMode(_ => Manual)
    beginInit()
    setTime(_ => 1)
  }

  let manualHandle = (y: int, x: int) => {
    switch mode {
    | Manual => {
        let (emptyY, emptyX) = emtyPosition.current
        if (
          (emptyX === x && (y + 1 === emptyY || y - 1 === emptyY)) ||
            (emptyY === y && (x + 1 === emptyX || x - 1 === emptyX))
        ) {
          squareRun((y, x))
        }
      }

    | Auto | Over => ()
    }
  }

  // a* 算法自动寻路
  let computedScore = (arr: array<array<int>>) => {
    let score = ref(0)
    arr->Belt.Array.forEachWithIndex((y, line) => {
      line->Belt.Array.forEachWithIndex((x, item) => {
        switch item {
        | 9 => ()
        | _ => {
            let endY = switch endArr->Belt_Array.getIndexBy(
              line => line->Belt_Array.some(xItem => xItem == item),
            ) {
            | Some(n) => n
            | None => 0
            }
            let endX = switch endArr->Belt_Array.get(endY) {
            | Some(line) =>
              switch line->Belt_Array.getIndexBy(xItem => xItem == item) {
              | Some(x) => x
              | None => 0
              }
            | None => 0
            }

            score := score.contents + Js.Math.abs_int(x - endX) + Js.Math.abs_int(y - endY)
          }
        }
      })
    })
    score.contents
  }

  let getNextList = (arr: array<array<int>>, (emptyY, emptyX): (int, int)) => {
    let nextPositions = [
      (emptyY + 1, emptyX),
      (emptyY - 1, emptyX),
      (emptyY, emptyX + 1),
      (emptyY, emptyX - 1),
    ]->Js.Array2.filter(((y, x)) => {
      switch arr->Belt.Array.get(y) {
      | Some(item) => item->Belt.Array.get(x)->Belt.Option.isSome
      | None => false
      }
    })

    nextPositions->Belt_Array.map(p => (p, virtualConvert(p, (emptyY, emptyX), arr)))
  }

  let computedAutoModeNext = () => {
    let openList: array<autoNode> = [
      {
        currentStatus: getDeepCloneJigsawArray(jigsawArrayRef.current),
        parent: None,
        id: genId(jigsawArrayRef.current),
        score: 100,
        step: 1,
        position: emtyPosition.current,
      },
    ]
    let closeList: originSet<string> = %raw(`new Set()`)

    let endNode: ref<option<autoNode>> = ref(None)
    while Belt.Option.isNone(endNode.contents) && openList->Belt.Array.size > 0 {
      let openNode = openList->Js.Array2.pop
      switch openNode {
      | Some(node) => {
          closeList.add(. node.id)->ignore

          let nextList = getNextList(node.currentStatus, node.position)
          let i = ref(0)
          while i.contents < nextList->Belt_Array.size {
            switch nextList->Belt_Array.get(i.contents) {
            | Some(next) => {
                let (nextPosition, nextStatus) = next
                let id = genId(nextStatus)

                switch closeList.has(. id) {
                | true => ()
                | false => {
                    let score = computedScore(nextStatus)
                    let parent = Js.Option.some(node)
                    let step = node.step + 1
                    let nextNode = {
                      id,
                      parent,
                      currentStatus: nextStatus,
                      score: lsl(score, 20) + lsl(step, 6) + node.score + score,
                      step,
                      position: nextPosition,
                    }
                    if isEnd(id) {
                      endNode := Some(nextNode)
                      i := nextList->Belt_Array.size
                    } else {
                      openList->Js.Array2.push(nextNode)->ignore
                    }
                  }
                }
              }

            | None => ()
            }
            i := -lnot(i.contents)
          }

          openList->Js.Array2.sortInPlaceWith((a, b) => b.score - a.score)->ignore
        }

      | None => ()
      }
    }

    path.current = switch endNode.contents {
    | Some(end) => {
        let thePath: array<(int, int)> = []
        let node = ref(end)
        while Belt.Option.isSome(node.contents.parent) {
          thePath->Js.Array2.push(node.contents.position)->ignore
          node := node.contents.parent->Belt.Option.getExn
        }

        thePath->Belt.Array.reverse
      }

    | None => []
    }
  }

  let autoGame = () => {
    beginInit()
    setIsPending(_ => true)
    startTransition(.() => {
      computedAutoModeNext()
      setTime(_ => 1)
      setMode(_ => Auto)
      setIsPending(_ => false)
    })
  }

  React.useEffect1(() => {
    switch Belt.Array.length(jigsawArray) {
    | 0 => None
    | _ =>
      if jigsawArray->genId->isEnd {
        setMode(_ => Over)
        setTime(_ => 0)
        let timer = Js.Global.setTimeout(() => {
          alert("You win!")
        }, 300)

        Some(() => Js.Global.clearTimeout(timer))
      } else {
        None
      }
    }
  }, [jigsawArray])
  React.useEffect2(() => {
    switch mode {
    | Manual | Over => None
    | Auto => {
        let timer = Js.Global.setTimeout(() => {
          squareRun(path.current[pathIdx.current])
          pathIdx.current = pathIdx.current + 1
        }, 350)
        let clenup = () => {
          Js.Global.clearTimeout(timer)
        }
        Some(clenup)
      }
    }
  }, (mode, pathIdx.current))
  React.useEffect1(() => {
    switch time {
    | 0 => None
    | _ => {
        let timer = Js.Global.setTimeout(() => setTime(_ => time + 1), 1000)

        let clenup = () => {
          Js.Global.clearTimeout(timer)
        }

        Some(clenup)
      }
    }
  }, [time])

  <div className="app">
    <h2> {"3*3"->React.string} </h2>
    <div>
      <div className="box">
        {Js.Array2.mapi(jigsawArray, (item, i1) => {
          Js.Array2.mapi(item, (n, i2) => {
            <div
              className="jigsaw-item"
              key={n->Belt.Int.toString}
              onClick={_ => manualHandle(i1, i2)}>
              {(n !== 9 ? n->Belt.Int.toString : " ")->React.string}
            </div>
          })->React.array
        })->React.array}
      </div>
      <div className="msg">
        <div> {`${isPending ? "wait" : ""}`->React.string} </div>
        <div> {`step: ${step->Belt.Int.toString}`->React.string} </div>
        <div> {`time: ${time->Belt.Int.toString} `->React.string} </div>
        <div> {`length: ${path.current->Belt.Array.size->Belt.Int.toString}`->React.string} </div>
      </div>
      <div className="btn">
        <button onClick={_e => manualGame()}> {"Play Game"->React.string} </button>
        <button onClick={_e => restGame()}> {"Rest Game"->React.string} </button>
        <button onClick={_e => autoGame()}> {"Auto Game"->React.string} </button>
      </div>
      <div className="version"> {"v2.2.0"->React.string} </div>
    </div>
  </div>
}
