
var AV = require('leancloud-storage');
var APP_ID = '0kdimTBPXBoAlr1vCQSzuSAK-gzGzoHsz';
var APP_KEY = 'BQYpqAYaoGjIm1xRFiIjMYIw';
AV.init({
        appId: APP_ID,
        appKey: APP_KEY
        });

App.onLaunch = function(options) {
    
    var alert
    
    AV.User.logIn('myname', 'mypass').then(function() {
                                           // Successful
                                           alert = createAlert("Successful", "Welcome to tvOS");
                                           }, function() {
                                           // Failed
                                           alert = createAlert("Failed", "Welcome to tvOS");
                                           });
    
    navigationDocument.pushDocument(alert);
}


App.onWillResignActive = function() {

}

App.onDidEnterBackground = function() {

}

App.onWillEnterForeground = function() {
    
}

App.onDidBecomeActive = function() {
    
}

App.onWillTerminate = function() {
    
}


/**
 * This convenience funnction returns an alert template, which can be used to present errors to the user.
 */
var createAlert = function(title, description) {

    var alertString = `<?xml version="1.0" encoding="UTF-8" ?>
        <document>
          <alertTemplate>
            <title>${title}</title>
            <description>${description}</description>
          </alertTemplate>
        </document>`

    var parser = new DOMParser();

    var alertDoc = parser.parseFromString(alertString, "application/xml");

    return alertDoc
}
