<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en" ng-app="Page2App">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page 2</title>
    
    <!-- Include header JSP -->
    <jsp:include page="header.jsp"/>
</head>
<body>
    <div ng-controller="Page2Controller" style="padding: 20px;">
        <h1>{{ 'PAGE2_HEADING' | translate }}</h1>
        <p>{{ 'PAGE2_TEXT' | translate }}</p>
        <p>{{ 'WELCOME_MESSAGE' | translate }}</p>
        <button>{{ 'BUTTON_CANCEL' | translate }}</button>
    </div>
    
    <!-- Include footer JSP -->
    <jsp:include page="footer.jsp"/>
    
    <script>
        // One line setup - automatically configures translation with page2.json + common.json
        var app = window.setupPageTranslation('Page2App', 'page2');
        
        app.controller('Page2Controller', ['$scope', '$translate', function($scope, $translate) {
            // Your existing code here...
            
            // One line to sync with global translation:
            window.syncTranslation($scope, $translate);
        }]);
    </script>
</body>
</html>
