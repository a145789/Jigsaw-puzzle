%%raw(`import './App.css'`)

@react.component
let make = () => {
  let (step, setStep) = React.useState(() => 0)
  let (time, setTime) = React.useState(() => 0)
  let (jigsawArray, setJigsawArray) = React.useState(() => [])

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

  let genArr = () => {
    let arr = [1, 2, 3, 4, 5, 6, 7, 8]
    Js.Array2.sortInPlaceWith(arr, (_, _) => Js.Math.random() > 0.5 ? 1 : -1)
  }

  let rest = () => {
    setStep(_ => 0)
    setTime(_ => 0)
  }

  let begin = () => {
    setStep(_ => 0)
    setTime(_ => 1)
    setJigsawArray(_ => [])
  }

  React.useEffect1(() => {
    let timer = ref(_)
    if time !== 0 {
      // Js.Global.setTimeout(() => setTime(_ => time + 1), 1000)
      let message = "Timed out!"

      let _ = Js.Global.setTimeout(() => Js.log(message), 1000)
    }
    let clenup = () => {
      // Js.clearTimeout(timer.contents)
      Js.log("cleaned up")
    }

    Some(clenup)
  }, [time])

  <div className="app">
    <h2> {"3*3"->React.string} </h2>
    <div>
      <h3>
        <div />
        <div className="btn">
          <button onClick={_e => begin()}> {"begin"->React.string} </button>
          <div> {`step: ${step->Belt.Int.toString}`->React.string} </div>
          <div> {`time: ${time->Belt.Int.toString} `->React.string} </div>
          <button onClick={_e => rest()}> {"rest"->React.string} </button>
        </div>
      </h3>
    </div>
  </div>
}
