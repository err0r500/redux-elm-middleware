import camelCase from 'camelcase'

export const ELM = '@@elm'

const createElmMiddleware = (elm) => {
  const elmMiddleware = ({dispatch}) => next => action => {
    const camelCaseType = camelCase(action.type)
    if (elm.ports && elm.ports[camelCaseType]) {
      const payload = typeof action.payload === undefined ? null : action.payload
      elm.ports[camelCaseType].send(payload)
    }
    next(action)
  }

  const run = store => {
    if (elm && elm.ports && elm.ports.elmToRedux) {
      elm.ports.elmToRedux.subscribe(([action, payload]) => {
        const [actionType, ...rest] = action.split(' ')
        store.dispatch({
          type: `${ELM}/${actionType}`,
          payload
        })
      })
    }
  }

  return {elmMiddleware, run}
}

export default createElmMiddleware

export const createElmReducer = (init) => (state = init, action) => {
  const [elmAction, type] = action.type.split('/')
  if (elmAction === ELM) {
    return action.payload
  }

  return state
}

export const reducer = createElmReducer({})
