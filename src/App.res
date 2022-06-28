%%raw(`import './App.css'`)

@val @scope("window")
external alert: string => unit = "alert"

@react.component
let make = () => {
  let (step, setStep) = React.useState(() => 0)
  let (time, setTime) = React.useState(() => 0)
  let notClicked = React.useRef(false)
  let (jigsawArray: array<array<int>>, setJigsawArray) = React.useState(() => [])
  let (emtyPosition: (int, int), setEmtyPosition) = React.useState(() => (2, 2))

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

  let rest = () => {
    setStep(_ => 0)
    setTime(_ => 0)
    setJigsawArray(_ => [])
    setEmtyPosition(_ => (2, 2))
  }

  let begin = () => {
    setTime(_ => 1)
    setJigsawArray(_ => genJigsaw()->Belt.Array.concat([9])->tearArr)
  }

  let auto = () => {
    begin()
    notClicked.current = true
  }

  let handle = (y: int, x: int) => {
    let (emptyY, emptyX) = emtyPosition
    if (
      (emptyX === x && (y + 1 === emptyY || y - 1 === emptyY)) ||
        (emptyY === y && (x + 1 === emptyX || x - 1 === emptyX))
    ) {
      setEmtyPosition(_ => (y, x))

      let result = jigsawArray[y][x]
      jigsawArray[y][x] = 9
      jigsawArray[emptyY][emptyX] = result
      setJigsawArray(_ => Js.Array.copy(jigsawArray))
      setStep(_ => step + 1)
    }
  }

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
        rest()
      }

      None
    }
  }, [jigsawArray])

  <div className="app">
    <h2> {"3*3"->React.string} </h2>
    <div>
      <div className="box">
        {Js.Array2.mapi(jigsawArray, (item, i1) => {
          Js.Array2.mapi(item, (n, i2) => {
            <div className="jigsaw-item" key={n->Belt.Int.toString} onClick={_ => handle(i1, i2)}>
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
        <button onClick={_e => begin()}> {"begin"->React.string} </button>
        <button onClick={_e => rest()}> {"rest"->React.string} </button>
        <button onClick={_e => auto()}> {"auto "->React.string} </button>
      </div>
    </div>
  </div>
}
