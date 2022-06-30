%%raw(`import './normal.css'`)

type r = {render: (. React.element) => unit}

@module("react-dom/client")
external createRoot: Dom.element => r = "createRoot"

let root = createRoot(ReactDOM.querySelector("#root")->Belt.Option.getExn)

root.render(. <React.StrictMode> <App /> </React.StrictMode>)
