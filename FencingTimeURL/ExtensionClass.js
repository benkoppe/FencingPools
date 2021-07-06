//
//  ExtensionClass.js
//  FencingTimeURL
//
//  Created by Ben K on 7/5/21.
//

var ExtensionClass = function() {};

ExtensionClass.prototype = {
    run: function(arguments) {
        arguments.completionFunction({
            "title": document.title
        });
    }
};

var ExtensionPreprocessingJS = new ExtensionClass;

