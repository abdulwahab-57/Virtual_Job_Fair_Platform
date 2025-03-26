// redux-thunk@2.4.2 downloaded from https://ga.jspm.io/npm:redux-thunk@2.4.2/es/index.js

function createThunkMiddleware(e){var t=function middleware(t){var r=t.dispatch,n=t.getState;return function(t){return function(a){return"function"===typeof a?a(r,n,e):t(a)}}};return t}var e=createThunkMiddleware();e.withExtraArgument=createThunkMiddleware;export{e as default};

