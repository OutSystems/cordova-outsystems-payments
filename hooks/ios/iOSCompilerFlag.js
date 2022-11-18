const path = require('path');
const fs = require('fs');
const xcode = require('xcode');
const { ConfigParser } = require('cordova-common');

module.exports = function (context) {

    const ServiceEnum = Object.freeze({"ApplePay":"1", "GooglePay":"2"})
    var projectRoot = context.opts.cordova.project ? context.opts.cordova.project.root : context.opts.projectRoot;

    var payment_service_provider = "";

    var appNamePath = path.join(projectRoot, 'config.xml');
    var appNameParser = new ConfigParser(appNamePath);
    var appName = appNameParser.name();

    let platformPath = path.join(projectRoot, 'platforms/ios');

    //read json config file
    var jsonConfig = "";
    try {
        jsonConfig = path.join(platformPath, 'www/json-config/PaymentsPluginConfiguration.json');
        var jsonConfigFile = fs.readFileSync(jsonConfig, 'utf8');
        console.log(jsonConfigFile);
        var jsonParsed = JSON.parse(jsonConfigFile);
        console.log(jsonParsed);
    } catch {
        throw new Error("Missing configuration file or error trying to obtain the configuration.");
    }
    
    jsonParsed.app_configurations.forEach(function(configItem) {
        if (configItem.service_id == ServiceEnum.ApplePay && configItem.tokenization != null && configItem.tokenization.gateway != null && configItem.tokenization.gateway !== "") {
            payment_service_provider = configItem.tokenization.gateway;
        }
        return;
    });

    if (payment_service_provider !== "") {
        const COMMENT_KEY = /_comment$/;
        let pbxprojPath = path.join(platformPath, appName + '.xcodeproj', 'project.pbxproj');
        let xcodeProject = xcode.project(pbxprojPath);
        xcodeProject.parseSync();

        let buildConfigs = xcodeProject.pbxXCBuildConfigurationSection();

        for (configName in buildConfigs) {
            if (!COMMENT_KEY.test(configName)) {
                buildConfig = buildConfigs[configName];

                var currentFlag = xcodeProject.getBuildProperty('SWIFT_ACTIVE_COMPILATION_CONDITIONS', buildConfig.name);
                var enableGateway = payment_service_provider.toUpperCase() + '_ENABLED';

                if (typeof currentFlag !== 'undefined' && !currentFlag.includes(enableGateway)) {
                    enableGateway = currentFlag + ' ' + current;
                }

                xcodeProject.updateBuildProperty('SWIFT_ACTIVE_COMPILATION_CONDITIONS', enableGateway, buildConfig.name);
            }
        }

        fs.writeFileSync(pbxprojPath, xcodeProject.writeSync());
    }    
};
