WhitelistManager = require 'meshblu-core-manager-whitelist'
http             = require 'http'

class CheckWhitelist
  constructor: ({datastore, @whitelistManager, uuidAliasResolver}) ->
    @whitelistManager ?= new WhitelistManager {datastore, uuidAliasResolver}

  do: (job, callback) =>
    {from, to, responseId, auth} = job.metadata
    from ?= auth.uuid
    broadcaster = from
    subscriber = to
    @whitelistManager.canGetBroadcastSent {broadcaster, subscriber}, (error, verified) =>
      return @sendResponse responseId, 500, callback if error?
      return @sendResponse responseId, 403, callback unless verified
      @sendResponse responseId, 204, callback

  sendResponse: (responseId, code, callback) =>
    callback null,
      metadata:
        responseId: responseId
        code: code
        status: http.STATUS_CODES[code]

module.exports = CheckWhitelist
