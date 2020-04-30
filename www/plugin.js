var exec = require('cordova/exec');


exports.getSdState =  function(cb) {
		exec(cb, null, "DatamiSDStateChangePlugin", 'getSDState', []);
};

exports.getAnalytics =  function(cb) {
		exec(cb, null, "DatamiSDStateChangePlugin", 'getAnalytics', []);
};

exports.updateUserId =  function(cb,userId) {
		exec(cb, null, "DatamiSDStateChangePlugin", 'updateUserId', [userId]);
};

exports.updateUserTag =  function(cb,tags) {
		exec(cb, null, "DatamiSDStateChangePlugin", 'updateUserTag', [tags]);
};

exports.getSDAuth =  function(cb,url) {
		exec(cb, null, "DatamiSDStateChangePlugin", 'getSDAuth', [url]);
};

exports.stopSponsoredData =  function(cb) {
		exec(cb, null, "DatamiSDStateChangePlugin", 'stopSponsoredData', []);
};

exports.startSponsoredData =  function(cb) {
		exec(cb, null, "DatamiSDStateChangePlugin", 'startSponsoredData', []);
};
exports.updateUserId =  function(cb,userId) {
		exec(cb, null, "DatamiSDStateChangePlugin", 'updateUserId', [userId]);
};

exports.updateUserTag =  function(cb,tags) {
		exec(cb, null, "DatamiSDStateChangePlugin", 'updateUserTag', [tags]);
};

exports.getSDAuth =  function(cb,url) {
		exec(cb, null, "DatamiSDStateChangePlugin", 'getSDAuth', [url]);
};