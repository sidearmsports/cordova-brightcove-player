var exec = require("cordova/exec");

exports.play = function (videoId, adConfigId, adTagId, success, error) {
  exec(success, error, "BrightcovePlayer", "play", [
    videoId,
    adConfigId,
    adTagId,
  ]);
};

exports.init = function (policyKey, accountId, success, error) {
  exec(success, error, "BrightcovePlayer", "initAccount", [
    policyKey,
    accountId,
  ]);
};

exports.switchAccountTo = function (policyKey, accountId, success, error) {
  exec(success, error, "BrightcovePlayer", "switchAccount", [
    policyKey,
    accountId,
  ]);
};
