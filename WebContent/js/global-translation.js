(function() {
    'use strict';
    
    window.GlobalTranslation = {
        currentLanguage: localStorage.getItem('selectedLanguage') || 'en',
        
        changeLanguage: function(langKey) {
            localStorage.setItem('selectedLanguage', langKey);
            this.currentLanguage = langKey;
            window.dispatchEvent(new CustomEvent('globalLanguageChanged', { detail: langKey }));
        },
        
        getCurrentLanguage: function() {
            return this.currentLanguage;
        }
    };
    
    // Enhanced translation initialization with support for page-specific JSON files
    window.initTranslation = function($translateProvider, pageTranslationFile) {
        var savedLang = window.GlobalTranslation.getCurrentLanguage();
        var contextPath = window.APP_CONTEXT_PATH || '';
        var i18nPath = contextPath + '/i18n/';
        
        // If page-specific file is provided, use custom loader that loads multiple files
        if (pageTranslationFile) {
            $translateProvider.useLoader('$translate', ['$q', '$http', function($q, $http) {
                return function(options) {
                    var lang = options.key || window.GlobalTranslation.getCurrentLanguage();
                    
                    var loadFile = function(file) {
                        return $http({
                            method: 'GET',
                            url: i18nPath + file + '_' + lang + '.json',
                            cache: true
                        }).then(
                            function(response) { return response.data; },
                            function() { return {}; } // Return empty object if file doesn't exist
                        );
                    };
                    
                    // Load common and page-specific files, then merge
                    return $q.all([
                        loadFile('common'),
                        loadFile(pageTranslationFile)
                    ]).then(function(results) {
                        // Merge: common first, then page-specific (page overrides common)
                        var merged = {};
                        angular.extend(merged, results[0]);
                        angular.extend(merged, results[1]);
                        return merged;
                    });
                };
            }]);
        } else {
            // Otherwise use standard loader for common file only
            $translateProvider.useStaticFilesLoader({
                prefix: i18nPath + 'common_',
                suffix: '.json'
            });
        }
        
        $translateProvider.preferredLanguage(savedLang);
        $translateProvider.useSanitizeValueStrategy('escape');
    };
    
    // Auto-setup function - minimal code needed in pages
    // Usage: window.setupPageTranslation('Page1App', 'page1');
    window.setupPageTranslation = function(appModule, pageTranslationFile) {
        var module = angular.module(appModule, ['pascalprecht.translate']);
        
        module.config(['$translateProvider', function($translateProvider) {
            window.initTranslation($translateProvider, pageTranslationFile);
        }]);
        
        return module;
    };
    
    // Auto-sync function - call this in each controller
    window.syncTranslation = function($scope, $translate) {
        var currentLang = window.GlobalTranslation.getCurrentLanguage();
        $translate.use(currentLang);
        
        window.addEventListener('globalLanguageChanged', function(event) {
            if (event.detail) {
                $translate.use(event.detail);
                if ($scope) $scope.$apply();
            }
        });
    };
})();
