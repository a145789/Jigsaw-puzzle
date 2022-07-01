%%raw(`import './App.css'`)

@val @scope("window")
external alert: string => unit = "alert"

type appMode = Manual | Auto | Over


type rec autoNode = {
  "parentStatus": option<autoNode>,
  "childStatus": array<autoNode>,
  "emptyCurrentPosition": (int, int),
} 



@react.component
let make = () => {
  let (step, setStep) = React.useState(() => 0)
  let (time, setTime) = React.useState(() => 0)
  let (jigsawArray: array<array<int>>, setJigsawArray) = React.useState(() => [])
  let (mode: appMode, setMode) = React.useState(() => Manual)

  let emtyPosition = React.useRef((2, 2))
  let prevEmptyOptions = React.useRef((2, 2))

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
    let result = Js.Array2.sortInPlaceWith([1, 2, 3, 4, 5, 6, 7, 8], (_, _) =>
      Js.Math.random() > 0.5 ? 1 : -1
    )
    if isUnsolvable(result) {
      genJigsaw()
    } else {
      result
    }
  }

  let tearArr = (arr: array<int>) => {
    [
      Js.Array2.slice(arr, ~start=0, ~end_=3),
      Js.Array2.slice(arr, ~start=3, ~end_=6),
      Js.Array2.slice(arr, ~start=6, ~end_=9),
    ]
  }

  let getDeepCloneJigsawArray = () => jigsawArray->Belt.Array.map(Belt.Array.copy)

  let restGame = () => {
    setStep(_ => 0)
    setTime(_ => 0)
    setJigsawArray(_ => [])
    emtyPosition.current = (2, 2)
    prevEmptyOptions.current = (2, 2)
  }

  let beginInit = () => {
    restGame()
    setTime(_ => 1)
    setJigsawArray(_ => genJigsaw()->Belt.Array.concat([9])->tearArr)
  }

  let virtualConvert = (nextY: int, nextX: int) => {
    let (emptyY, emptyX) = emtyPosition.current
    let jigsawArrayCopy = getDeepCloneJigsawArray()

    let replaceValue = jigsawArrayCopy[nextY][nextX]
    jigsawArrayCopy[nextY][nextX] = 9
    jigsawArrayCopy[emptyY][emptyX] = replaceValue

    jigsawArrayCopy
  }

  let squareRun = (nextY: int, nextX: int) => {
    let a = virtualConvert(nextY, nextX)
    setJigsawArray(_ => a)
    setStep(_ => step + 1)
    prevEmptyOptions.current = emtyPosition.current
    emtyPosition.current = (nextY, nextX)
  }

  let manualGame = () => {
    setMode(_ => Manual)
    beginInit()
  }

  let manualHandle = (y: int, x: int) => {
    switch mode {
    | Manual => {
        let (emptyY, emptyX) = emtyPosition.current
        if (
          (emptyX === x && (y + 1 === emptyY || y - 1 === emptyY)) ||
            (emptyY === y && (x + 1 === emptyX || x - 1 === emptyX))
        ) {
          squareRun(y, x)
        }
      }
    | Auto | Over => ()
    }
  }

  let computedAutoModeNext = () => {
    let getTurePosition = (num: int) => {
      let x = ref(0)
      let y = switch [(1, 2, 3), (4, 5, 6), (7, 8, 9)]->Belt.Array.getIndexBy(((a, b, c)) => {
        switch [a, b, c]->Belt.Array.getIndexBy(item => item === num) {
        | Some(xIdx) => {
            x := xIdx
            true
          }
        | None => false
        }
      }) {
      | Some(findY) => findY
      | None => 0
      }

      (y, x.contents)
    }

    let (emptyY, emptyX) = emtyPosition.current
    let node: autoNode = {
      "parentStatus": None,
      "childStatus": [],
      "emptyCurrentPosition": emtyPosition.current,
    }

    let nextEmptyPositions = Js.Array2.filter(
      [(emptyY + 1, emptyX), (emptyY - 1, emptyX), (emptyY, emptyX + 1), (emptyY, emptyX - 1)],
      ((y, x)) => {
        let (prevEmptyY, prevEmptyX) = prevEmptyOptions.current
        if prevEmptyY === y && prevEmptyX === x {
          false
        } else {
          switch jigsawArray->Belt.Array.get(y) {
          | Some(item) => item->Belt.Array.get(x)->Belt.Option.isSome
          | None => false
          }
        }
      },
    )

    let i = ref(0)
    let score = ref(100000)
    let bestResult = ref(i.contents)
    while i.contents < Belt.Array.size(nextEmptyPositions) {
      let (nextY, nextX) = nextEmptyPositions[i.contents]
      let newJigsawArray = virtualConvert(nextY, nextX)
      let currentScore = newJigsawArray->Belt.Array.reduceWithIndex(0, (_score, line, y) => {
        line->Belt.Array.reduceWithIndex(_score, (__score, item, x) => {
          if item !== 9 {
            let (trueY, trueX) = getTurePosition(item)
            __score + Js.Math.abs_int(y - trueY) + Js.Math.abs_int(x - trueX)
          } else {
            __score
          }
        })
      })
      // Js.log2(currentScore, score.contents)
      if currentScore < score.contents {
        bestResult := i.contents
        score := currentScore
      }

      i := i.contents + 1
    }
    // Js.log2(bestResult.contents, score.contents)
    let (nextY, nextX) = nextEmptyPositions[bestResult.contents]
    squareRun(nextY, nextX)
  }

  let autoGame = () => {
    setMode(_ => Auto)
    beginInit()
  }

  React.useEffect1(() => {
    switch Belt.Array.length(jigsawArray) {
    | 0 => None
    | _ =>
      if (
        !Js.Array2.somei(jigsawArray, (item, i1) =>
          Js.Array2.somei(item, (e, i2) => e !== 3 * i1 + i2 + 1)
        )
      ) {
        alert("You win!")
        setMode(_ => Over)
        setTime(_ => 0)
        None
      } else {
        switch mode {
        | Manual | Over => None
        | Auto => {
            let timer = Js.Global.setTimeout(() => computedAutoModeNext(), 1000)
            let clenup = () => {
              Js.Global.clearTimeout(timer)
            }
            Some(clenup)
          }
        }
      }
    }
  }, [jigsawArray])
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
        <div> {`step: ${step->Belt.Int.toString}`->React.string} </div>
        <div> {`time: ${time->Belt.Int.toString} `->React.string} </div>
      </div>
      <div className="btn">
        <button onClick={_e => manualGame()}> {"Play Game"->React.string} </button>
        <button onClick={_e => restGame()}> {"Rest Game"->React.string} </button>
        <button onClick={_e => autoGame()}> {"Auto Game"->React.string} </button>
      </div>
      <div className="version"> {"v1.0.0"->React.string} </div>
    </div>
  </div>
}

// <script>
// https://github.com/JiongXing/PuzzleGame
//         // use A* solve 8 puzzle problem?
//         // A* algorithm:
//         // 1. start from the begining point
//         // 2. find the nearest point to the end point
//         // 3. if the point is the end point, stop
//         // 4. if the point is not the end point, find the nearest point to the end point

//         const startArr = [[8, 4, 5], [6, 1, 2], [3, 7, 9]]
//         const endArr = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

//         function getArrClone(arr) {
//             return arr.map(item => [...item])
//         }

//         function isEnd(arr) {
//             return startArr.flat() === endArr.flat()
//         }

//         function computed(arr) {
//             let i = 0
//             endArr.forEach((item, y) => {
//                 item.forEach((a, x) => {
//                     if (a === 9) {
//                         return
//                     }
//                     const [y1,x1] = getPosition(arr, a)
//                     i += Math.abs(y - y1) + Math.abs(x - x1)
//                 })
//             })
//             return i
//         }

//         function replacement(arr, oldPosition, newPosition) {
//             const arrC = getArrClone(arr)
//             const temp = arrC[oldPosition.y][oldPosition.x]
//             arrC[oldPosition.y][oldPosition.x] = arrC[newPosition.y][newPosition.x]
//             arrC[newPosition.y][newPosition.x] = temp
//             return arrC
//         }

//         function getPosition(arr, s) {
//             const y = arr.findIndex(item => item.find(i => i === s))
//             const x = arr[y].findIndex(item => item === s)
//             return [y, x]
//         }

//         function getNextArr(arr) {
//             const nextArr = []
//             const [y, x] = getPosition(arr, 9)
//             if (arr[y + 1]?.[x]) {
//                 nextArr.push(replacement(arr, { y, x }, { y: y + 1, x }))
//             }
//             if (arr[y - 1]?.[x]) {
//                 nextArr.push(replacement(arr, { y, x }, { y: y - 1, x }))

//             }
//             if (arr[y][x + 1]) {
//                 nextArr.push(replacement(arr, { y, x }, { y, x: x + 1 }))
//             }
//             if (arr[y][x - 1]) {
//                 nextArr.push(replacement(arr, { y, x }, { y, x: x - 1 }))
//             }

//             return nextArr

//         }

//         function genId(arr) {
//             return arr.flat().reduce((p, c) => {
//                 return `${p}${c}`
//             }, 0)
//         }

//         function init() {
//             const openList = []
//             const closeList = []
//             openList.push({
//                 id: genId(startArr),
//                 currentArr: getArrClone(startArr),
//                 value: 0
//             })

//             while (openList.length) {
//                 const current = openList.shift()
//                 if (isEnd(current.currentArr)) {
//                     console.log(current.currentArr)
//                     return
//                 }
//                 closeList.push(current.id)
//                 const nextArr = getNextArr(current.currentArr)
//                 nextArr.forEach(item => {
//                     const id = genId(item)
//                     if (closeList.includes(id)) return
//                     const value = computed(item)
//                     openList.push({
//                         id,
//                         currentArr: item,
//                         value
//                     })
//                 })
//                 openList.sort((a, b) => a.value - b.value)
//             }
//         }
//  init()

//     </script>
