const et = require('elementtree');
const path = require('path');
const fs = require('fs');
const { ConfigParser } = require('cordova-common');
const { Console } = require('console');

module.exports = function (context) {

    const ServiceEnum = Object.freeze({"ApplePay":"1", "GooglePay":"2"})
    var projectRoot = context.opts.cordova.project ? context.opts.cordova.project.root : context.opts.projectRoot;

    var merchant_id = "";
    var merchant_name = "";
    var merchant_country_code = "";
    var payment_allowed_networks = [];
    var payment_supported_capabilities = [];
    var payment_supported_card_countries = [];
    var shipping_supported_contacts = [];
    var billing_supported_contacts = [];

    var appNamePath = path.join(projectRoot, 'config.xml');
    var appNameParser = new ConfigParser(appNamePath);
    var appName = appNameParser.name();

    //read json config file
    var jsonConfig = "";
    try {
        jsonConfig = path.join(projectRoot, 'platforms/ios/www/json-config/PaymentsPluginConfiguration.json');
        var jsonConfigFile = fs.readFileSync(jsonConfig).toString();
        var jsonParsed = JSON.parse(jsonConfigFile);
    
        jsonParsed.app_configurations.forEach(function(configItem) {
            if (configItem.service_id == ServiceEnum.ApplePay) {
                merchant_id = configItem.merchant_id;
                merchant_name = configItem.merchant_name;
                merchant_country_code = configItem.merchant_country_code;
                payment_allowed_networks = configItem.payment_allowed_networks;
                payment_supported_capabilities = configItem.payment_supported_capabilities;
                payment_supported_card_countries = configItem.payment_supported_card_countries;
                shipping_supported_contacts = configItem.shipping_supported_contacts;
                billing_supported_contacts = configItem.billing_supported_contacts;
            }
        });
    } catch {
        throw new Error("Missing configuration file or error trying to obtain the configuration.");
    }

    //Change info.plist
    var infoPlistPath = path.join(projectRoot, 'platforms/ios/' + appName + '/'+ appName +'-info.plist');
    var infoPlistFile = fs.readFileSync(infoPlistPath).toString();
    var etreeInfoPlist = et.parse(infoPlistFile);

    var infoPlistTags = etreeInfoPlist.findall('./dict/string');

    for (var i = 0; i < infoPlistTags.length; i++) {
        if (infoPlistTags[i].text.includes("APPLE_PAY_MERCHANT_ID")) {
            infoPlistTags[i].text = merchant_id;
        }
        if (infoPlistTags[i].text.includes("APPLE_PAY_MERCHANT_NAME")) {
            infoPlistTags[i].text = merchant_name;
        }
        if (infoPlistTags[i].text.includes("APPLE_PAY_MERCHANT_COUNTRY_CODE")) {
            infoPlistTags[i].text = merchant_country_code;
        }
        if (infoPlistTags[i].text.includes("APPLE_PAY_PAYMENT_ALLOWED_NETWORKS")) {
            infoPlistTags[i].text = payment_allowed_networks;
        }
        if (infoPlistTags[i].text.includes("APPLE_PAY_PAYMENT_SUPPORTED_CAPABILITIES")) {
            infoPlistTags[i].text = payment_supported_capabilities;
        }
        if (infoPlistTags[i].text.includes("APPLE_PAY_PAYMENT_SUPPORTED_CARD_COUNTRIES")) {
            infoPlistTags[i].text = payment_supported_card_countries;
        }
        if (infoPlistTags[i].text.includes("APPLE_PAY_SHIPPING_SUPPORTED_CONTACTS")) {
            infoPlistTags[i].text = shipping_supported_contacts;
        }
        if (infoPlistTags[i].text.includes("APPLE_PAY_BILLING_SUPPORTED_CONTACTS")) {
            infoPlistTags[i].text = billing_supported_contacts;
        }
    }

    var resultXmlInfoPlist = etreeInfoPlist.write();
    fs.writeFileSync(infoPlistPath, resultXmlInfoPlist);

    // Change Entitlements file
    var debugEntitlementsPath = path.join(projectRoot, 'platforms/ios/' + appName + '/'+ 'Entitlements-Debug.plist');
    var debugEntitlementsFile = fs.readFileSync(debugEntitlementsPath).toString();
    var eTreeDebugEntitlements = et.parse(debugEntitlementsFile);
    var debugEntitlementsTags = eTreeDebugEntitlements.findall('./dict/array/string');

    for (var i = 0; i < debugEntitlementsTags.length; i++) {
        if (debugEntitlementsTags[i].text.includes("APPLE_PAY_MERCHANT_ID")) {
            debugEntitlementsTags[i].text = merchant_id;
        }
    }

    var resultXmlDebugEntitlements = eTreeDebugEntitlements.write();
    fs.writeFileSync(debugEntitlementsPath, resultXmlDebugEntitlements);

    var releaseEntitlementsPath = path.join(projectRoot, 'platforms/ios/' + appName + '/' + 'Entitlements-Release.plist');
    var releaseEntitlementsFile = fs.readFileSync(releaseEntitlementsPath).toString();
    var eTreeReleaseEntitlements = et.parse(releaseEntitlementsFile);
    var releaseEntitlementsTags = eTreeReleaseEntitlements.findall('./dict/array/string');

    for (var i = 0; i < releaseEntitlementsTags.length; i++) {
        if (releaseEntitlementsTags[i].text.includes("APPLE_PAY_MERCHANT_ID")) {
            releaseEntitlementsTags[i].text = merchant_id;
        }
    }

    var resultXmlReleaseEntitlements = eTreeReleaseEntitlements.write();
    fs.writeFileSync(releaseEntitlementsPath, resultXmlReleaseEntitlements);
};
