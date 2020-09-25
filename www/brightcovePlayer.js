var exec = require("cordova/exec");

exports.play = function (options, success, error) {
  const { videoId, adConfigId, adTagId } = options;
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
