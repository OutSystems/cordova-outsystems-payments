const et = require('elementtree');
const path = require('path');
const fs = require('fs');

module.exports = function (context) {


    const ServiceEnum = Object.freeze({"ApplePay":"1", "GooglePay":"2"})
    const configFileName = 'www/json-config/PaymentsPluginConfiguration.json';

    var merchant_id = "";
    var merchant_name = "";
    var merchant_country_code = "";
    var payment_allowed_networks = [];
    var payment_supported_capabilities = [];
    var payment_supported_card_countries = [];
    var shipping_supported_contacts = [];
    var billing_supported_contacts = [];

    var projectRoot = context.opts.cordova.project ? context.opts.cordova.project.root : context.opts.projectRoot;

    //read json config file       www/jsonConfig/PaymentsPluginConfiguration.json
    var jsonConfig = "";
    try {
        jsonConfig = path.join(projectRoot, configFileName);
        var jsonConfigFile = fs.readFileSync(jsonConfig).toString();
        var jsonParsed = JSON.parse(jsonConfigFile);

        jsonParsed.app_configurations.forEach(function(configItem) {
            if (configItem.service_id == ServiceEnum.GooglePay) {
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

    var stringsXmlPath = path.join(projectRoot, 'platforms/android/app/src/main/res/values/strings.xml');
    var stringsXmlContents = fs.readFileSync(stringsXmlPath).toString();
    var etreeStrings = et.parse(stringsXmlContents);

    var stringTags = etreeStrings.findall('./string');
    for (var i = 0; i < stringTags.length; i++) {
        if(stringTags[i].text.includes("MERCHANT_NAME")){
            stringTags[i].text = stringTags[i].text.replace("MERCHANT_NAME", merchant_name)
        }
    }

    /*
    var stringTagsSecond = etreeStrings.findall('./string[@name="merchant_name"]');
    for (var i = 0; i < stringTagsSecond.length; i++) {
        var data = stringTagsSecond[i];
        data.text = merchant_name;
    }
    */
    
    var resultXmlStrings = etreeStrings.write();
    fs.writeFileSync(stringsXmlPath, resultXmlStrings);
    
};


