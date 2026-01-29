<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!-- Set context path for translation files -->
<script>
    window.APP_CONTEXT_PATH = '<%=request.getContextPath()%>';
</script>
<!-- Load global helper FIRST -->
<script src="<%=request.getContextPath()%>/js/global-translation.js"></script>

<!-- AngularJS and angular-translate -->
<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.8.2/angular.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/angular-translate/2.18.4/angular-translate.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/angular-translate-loader-static-files/2.18.4/angular-translate-loader-static-files.min.js"></script>

<!-- Header Dropdown -->
<header style="background-color: #f0f0f0; padding: 10px; border-bottom: 2px solid #ccc;">
    <div style="display: flex; justify-content: space-between; align-items: center;">
        <h1 style="margin: 0;">My Application</h1>
        
        <div ng-app="HeaderApp" ng-controller="HeaderController" style="display: inline-block;">
            <select ng-model="selectedLang" ng-change="changeLang(selectedLang)" style="padding: 5px 10px; font-size: 14px;">
                <option value="en">English</option>
                <option value="hi">Hindi</option>
                <option value="mr">Marathi</option>
            </select>
        </div>
    </div>
</header>

<script>
    angular.module('HeaderApp', ['pascalprecht.translate'])
        .config(['$translateProvider', function($translateProvider) {
            window.initTranslation($translateProvider);
        }])
        .controller('HeaderController', ['$scope', '$translate', function($scope, $translate) {
            $scope.selectedLang = window.GlobalTranslation.getCurrentLanguage();
            $scope.changeLang = function(lang) {
                window.GlobalTranslation.changeLanguage(lang);
                $translate.use(lang);
            };
            window.syncTranslation($scope, $translate);
        }]);
</script>
