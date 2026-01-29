<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en" ng-app="Page1App">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page 1</title>
    
    <!-- Include header JSP -->
    <jsp:include page="header.jsp"/>
</head>
<body>
    <div ng-controller="Page1Controller" style="padding: 20px;">
        <h1>{{ 'PAGE1_HEADING' | translate }}</h1>
        <p>{{ 'PAGE1_TEXT' | translate }}</p>
        <p>{{ 'WELCOME_MESSAGE' | translate }}</p>
        <button>{{ 'BUTTON_SUBMIT' | translate }}</button>
    </div>
    
    <!-- Include footer JSP -->
    <jsp:include page="footer.jsp"/>
    
    <script>
        // One line setup - automatically configures translation with page1.json + common.json
        var app = window.setupPageTranslation('Page1App', 'page1');
        
        app.controller('Page1Controller', ['$scope', '$translate', function($scope, $translate) {
            // Your existing code here...
            
            // One line to sync with global translation:
            window.syncTranslation($scope, $translate);
        }]);
    </script>
</body>
</html>
