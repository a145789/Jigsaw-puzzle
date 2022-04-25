%%raw(`import './normal.css'`)
%%raw(`import 'uno.css'`)

ReactDOM.render(
  <React.StrictMode> <App /> </React.StrictMode>,
  ReactDOM.querySelector("#root")->Belt.Option.getExn,
)
