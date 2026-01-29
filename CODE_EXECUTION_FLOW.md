# Code Execution Flow - Step by Step

## 🎯 Complete Execution Flow with Code References

### Scenario: User Opens Page1, Then Changes Language to Hindi

---

## Phase 1: Page Load (Initial State)

### Step 1: Browser Requests Page1
```
URL: http://localhost:8080/global-translation/page1
↓
Spring MVC DispatcherServlet receives request
↓
PageController.page1() returns "page1"
↓
View Resolver resolves to: /WEB-INF/views/page1.jsp
```

### Step 2: JSP Renders - Header Included First

**File: `page1.jsp`**
```jsp
<jsp:include page="header.jsp"/>
```

**What happens**:
1. JSP includes `header.jsp` content
2. `header.jsp` executes FIRST (before page1 content)

### Step 3: Header Sets Up Global Context

**File: `header.jsp` (Lines 3-5)**
```javascript
window.APP_CONTEXT_PATH = '/global-translation';
```

**Result**: Context path stored globally for translation file paths.

### Step 4: Global Translation Script Loads

**File: `header.jsp` (Line 7)**
```html
<script src="/global-translation/js/global-translation.js"></script>
```

**File: `global-translation.js` (Lines 4-16)**
```javascript
window.GlobalTranslation = {
    currentLanguage: localStorage.getItem('selectedLanguage') || 'en',
    // ↑ Checks localStorage, if empty defaults to 'en'
    
    changeLanguage: function(langKey) { ... },
    getCurrentLanguage: function() { ... }
};
```

**Execution**:
- Script loads and executes immediately
- `GlobalTranslation` object created
- Checks `localStorage.getItem('selectedLanguage')`
- If found: uses saved language (e.g., 'hi')
- If not found: defaults to 'en'

**Example**: If user previously selected Hindi:
```javascript
currentLanguage = localStorage.getItem('selectedLanguage') // Returns 'hi'
```

### Step 5: AngularJS Libraries Load

**File: `header.jsp` (Lines 10-12)**
```html
<script src="angular.min.js"></script>
<script src="angular-translate.min.js"></script>
<script src="angular-translate-loader-static-files.min.js"></script>
```

**Result**: AngularJS and translation library ready.

### Step 6: HeaderApp Initializes

**File: `header.jsp` (Lines 30-42)**
```javascript
angular.module('HeaderApp', ['pascalprecht.translate'])
    .config(['$translateProvider', function($translateProvider) {
        window.initTranslation($translateProvider);  // No page file - uses common only
    }])
    .controller('HeaderController', ['$scope', '$translate', function($scope, $translate) {
        $scope.selectedLang = window.GlobalTranslation.getCurrentLanguage();
        // ↑ Sets dropdown to current language (e.g., 'hi')
        
        $scope.changeLang = function(lang) {
            window.GlobalTranslation.changeLanguage(lang);
            $translate.use(lang);
        };
        
        window.syncTranslation($scope, $translate);
        // ↑ Connects header to global language changes
    }]);
```

**Execution Flow**:
1. `HeaderApp` module created
2. `.config()` runs FIRST (before controller)
3. `initTranslation($translateProvider, undefined)` called
   - Since no page file specified, uses `common_XX.json` only
4. Controller initializes
5. Dropdown shows current language (from localStorage)

### Step 7: Page1App Initializes

**File: `page1.jsp` (Lines 23-32)**
```javascript
var app = window.setupPageTranslation('Page1App', 'page1');
// ↑ Creates Page1App module with translation support
```

**File: `global-translation.js` (Lines 68-76)**
```javascript
window.setupPageTranslation = function(appModule, pageTranslationFile) {
    var module = angular.module(appModule, ['pascalprecht.translate']);
    // ↑ Creates 'Page1App' module
    
    module.config(['$translateProvider', function($translateProvider) {
        window.initTranslation($translateProvider, pageTranslationFile);
        // ↑ Calls initTranslation with 'page1' as page file
    }]);
    
    return module;
};
```

**Execution**:
1. `Page1App` module created
2. `.config()` runs
3. `initTranslation($translateProvider, 'page1')` called

### Step 8: Translation Loader Configured

**File: `global-translation.js` (Lines 19-64)**
```javascript
window.initTranslation = function($translateProvider, pageTranslationFile) {
    var savedLang = window.GlobalTranslation.getCurrentLanguage(); // 'hi' (from localStorage)
    var contextPath = window.APP_CONTEXT_PATH; // '/global-translation'
    var i18nPath = contextPath + '/i18n/'; // '/global-translation/i18n/'
    
    if (pageTranslationFile) { // 'page1' is truthy
        $translateProvider.useLoader('$translate', ['$q', '$http', function($q, $http) {
            return function(options) {
                var lang = options.key || window.GlobalTranslation.getCurrentLanguage();
                // ↑ Gets language from options or defaults to saved language
                
                var loadFile = function(file) {
                    return $http.get(i18nPath + file + '_' + lang + '.json')
                    // ↑ Example: '/global-translation/i18n/common_hi.json'
                        .then(
                            function(response) { return response.data; },
                            function() { return {}; }
                        );
                };
                
                return $q.all([
                    loadFile('common'),      // Loads common_hi.json
                    loadFile('page1')        // Loads page1_hi.json
                ]).then(function(results) {
                    var merged = {};
                    angular.extend(merged, results[0]); // common_hi.json content
                    angular.extend(merged, results[1]); // page1_hi.json content (overrides)
                    return merged;
                });
            };
        }]);
    }
    
    $translateProvider.preferredLanguage(savedLang); // Sets 'hi' as preferred
};
```

**Execution**:
1. Custom loader function registered
2. Loader will be called when translations needed
3. Preferred language set to 'hi'

### Step 9: Translation Files Loaded (Lazy)

**When Angular needs translations** (first `{{ 'KEY' | translate }}` evaluated):

**HTTP Request 1**: `GET /global-translation/i18n/common_hi.json`
```json
{
  "WELCOME_MESSAGE": "हमारे एप्लिकेशन में आपका स्वागत है!",
  "BUTTON_SUBMIT": "जमा करें"
}
```

**HTTP Request 2**: `GET /global-translation/i18n/page1_hi.json`
```json
{
  "PAGE1_HEADING": "पृष्ठ 1 शीर्षक",
  "PAGE1_TEXT": "यह अंग्रेजी में पृष्ठ 1 की सामग्री है।"
}
```

**Merged Result**:
```javascript
{
  "WELCOME_MESSAGE": "हमारे एप्लिकेशन में आपका स्वागत है!",
  "BUTTON_SUBMIT": "जमा करें",
  "PAGE1_HEADING": "पृष्ठ 1 शीर्षक",
  "PAGE1_TEXT": "यह अंग्रेजी में पृष्ठ 1 की सामग्री है।"
}
```

### Step 10: Page1Controller Initializes

**File: `page1.jsp` (Lines 27-31)**
```javascript
app.controller('Page1Controller', ['$scope', '$translate', function($scope, $translate) {
    window.syncTranslation($scope, $translate);
    // ↑ Connects page to global language changes
}]);
```

**File: `global-translation.js` (Lines 79-89)**
```javascript
window.syncTranslation = function($scope, $translate) {
    var currentLang = window.GlobalTranslation.getCurrentLanguage(); // 'hi'
    $translate.use(currentLang); // Sets language to 'hi'
    
    window.addEventListener('globalLanguageChanged', function(event) {
        // ↑ Listens for language change events
        if (event.detail) {
            $translate.use(event.detail); // Changes language
            if ($scope) $scope.$apply(); // Updates Angular bindings
        }
    });
};
```

**Execution**:
1. Controller created
2. `syncTranslation()` called
3. Current language ('hi') applied
4. Event listener registered for future changes

### Step 11: HTML Rendered with Translations

**File: `page1.jsp` (Lines 13-17)**
```html
<h1>{{ 'PAGE1_HEADING' | translate }}</h1>
<p>{{ 'PAGE1_TEXT' | translate }}</p>
<p>{{ 'WELCOME_MESSAGE' | translate }}</p>
```

**Angular Evaluation**:
1. `{{ 'PAGE1_HEADING' | translate }}`
   - Filter calls `$translate.instant('PAGE1_HEADING')`
   - Looks up in merged translations
   - Returns `"पृष्ठ 1 शीर्षक"`
   - Renders: `<h1>पृष्ठ 1 शीर्षक</h1>`

2. `{{ 'WELCOME_MESSAGE' | translate }}`
   - Returns `"हमारे एप्लिकेशन में आपका स्वागत है!"`
   - Renders: `<p>हमारे एप्लिकेशन में आपका स्वागत है!</p>`

**Final HTML**:
```html
<h1>पृष्ठ 1 शीर्षक</h1>
<p>यह अंग्रेजी में पृष्ठ 1 की सामग्री है।</p>
<p>हमारे एप्लिकेशन में आपका स्वागत है!</p>
```

---

## Phase 2: User Changes Language (English → Hindi)

### Step 12: User Clicks Dropdown

**User Action**: Clicks dropdown, selects "English"

**File: `header.jsp` (Line 20)**
```html
<select ng-model="selectedLang" ng-change="changeLang(selectedLang)">
```

**Angular**: Detects `ng-change` event, calls `changeLang('en')`

### Step 13: HeaderController.changeLang() Executes

**File: `header.jsp` (Lines 36-39)**
```javascript
$scope.changeLang = function(lang) {
    window.GlobalTranslation.changeLanguage(lang);  // Step A
    $translate.use(lang);                          // Step B
};
```

**Execution**: `changeLang('en')` called

### Step 14: GlobalTranslation.changeLanguage() Executes

**File: `global-translation.js` (Lines 7-11)**
```javascript
changeLanguage: function(langKey) {
    localStorage.setItem('selectedLanguage', langKey);
    // ↑ Saves 'en' to localStorage
    
    this.currentLanguage = langKey;
    // ↑ Updates in-memory value to 'en'
    
    window.dispatchEvent(new CustomEvent('globalLanguageChanged', { detail: langKey }));
    // ↑ Fires event with 'en' as detail
}
```

**Execution**:
1. `localStorage.setItem('selectedLanguage', 'en')` - Saved!
2. `this.currentLanguage = 'en'` - Updated!
3. Event fired: `globalLanguageChanged` with `detail: 'en'`

**Event Details**:
```javascript
{
    type: 'globalLanguageChanged',
    detail: 'en',
    bubbles: true,
    cancelable: false
}
```

### Step 15: Event Propagates to All Listeners

**All pages with `syncTranslation()` receive the event:**

**Page1** (via `syncTranslation()` listener):
```javascript
window.addEventListener('globalLanguageChanged', function(event) {
    // event.detail = 'en'
    $translate.use(event.detail);  // Changes Page1App's language to 'en'
    $scope.$apply();              // Triggers Angular digest cycle
});
```

**Header** (via `syncTranslation()` listener):
```javascript
window.addEventListener('globalLanguageChanged', function(event) {
    // event.detail = 'en'
    $translate.use(event.detail);  // Changes HeaderApp's language to 'en'
    $scope.$apply();              // Updates dropdown display
});
```

**If Page2 is open** (also receives event):
```javascript
window.addEventListener('globalLanguageChanged', function(event) {
    // event.detail = 'en'
    $translate.use(event.detail);  // Changes Page2App's language to 'en'
    $scope.$apply();              // Updates Page2 content
});
```

### Step 16: Translation Files Reloaded

**When `$translate.use('en')` is called:**

**Loader Function Executes** (from Step 8):
```javascript
return function(options) {
    var lang = options.key; // 'en'
    
    return $q.all([
        loadFile('common'),   // Loads common_en.json
        loadFile('page1')     // Loads page1_en.json
    ]).then(function(results) {
        // Merge and return
    });
};
```

**HTTP Requests**:
1. `GET /global-translation/i18n/common_en.json`
2. `GET /global-translation/i18n/page1_en.json`

**New Merged Translations**:
```javascript
{
  "WELCOME_MESSAGE": "Welcome to our application!",
  "BUTTON_SUBMIT": "Submit",
  "PAGE1_HEADING": "Page 1 Heading",
  "PAGE1_TEXT": "This is the content for Page 1 in English."
}
```

### Step 17: Angular Re-evaluates All Bindings

**File: `page1.jsp`**
```html
<h1>{{ 'PAGE1_HEADING' | translate }}</h1>
```

**Angular Process**:
1. `$scope.$apply()` triggers digest cycle
2. All `{{ }}` expressions re-evaluated
3. `translate` filter called again
4. New translations looked up
5. DOM updated

**Before** (Hindi):
```html
<h1>पृष्ठ 1 शीर्षक</h1>
```

**After** (English):
```html
<h1>Page 1 Heading</h1>
```

**Result**: Page updates INSTANTLY without reload!

---

## Phase 3: User Navigates to Page2

### Step 18: User Clicks Link to Page2

**URL Changes**: `/page1` → `/page2`

### Step 19: Page2 Loads (Same Process as Page1)

**File: `page2.jsp`**
```javascript
var app = window.setupPageTranslation('Page2App', 'page2');
```

**Execution**:
1. `Page2App` module created
2. `initTranslation($translateProvider, 'page2')` called
3. Loader configured for `common` + `page2` files
4. `GlobalTranslation.getCurrentLanguage()` returns `'en'` (from localStorage)
5. Loads `common_en.json` + `page2_en.json`
6. Page2 displays in English automatically!

**Key Point**: Language persists because it's read from `localStorage`!

---

## 🔑 Key Takeaways

### 1. **localStorage is the Source of Truth**
- Language stored: `localStorage.getItem('selectedLanguage')`
- Survives page reloads
- Survives navigation
- All pages read from same source

### 2. **Event System Connects All Pages**
- Header fires `globalLanguageChanged` event
- All pages listen via `syncTranslation()`
- No direct page-to-page communication needed

### 3. **Lazy Loading**
- Translation files loaded on-demand
- Only when language changes
- Cached by browser

### 4. **Merging Strategy**
- Common translations loaded first
- Page-specific loaded second
- Page-specific overrides common (same key)

### 5. **Angular Does the Heavy Lifting**
- `$translate.use()` triggers reload
- `$scope.$apply()` updates bindings
- `{{ 'KEY' | translate }}` automatically re-evaluates

---

## 📊 Visual Timeline

```
Time →
│
├─ Page1 Loads
│  ├─ Header includes scripts
│  ├─ GlobalTranslation object created
│  ├─ Checks localStorage → 'hi' (or 'en' if first time)
│  ├─ HeaderApp initializes
│  ├─ Page1App initializes
│  ├─ Loads common_hi.json + page1_hi.json
│  ├─ Merges translations
│  └─ Renders page in Hindi
│
├─ User Clicks Dropdown → Selects "English"
│  ├─ changeLang('en') called
│  ├─ localStorage.setItem('selectedLanguage', 'en')
│  ├─ Event 'globalLanguageChanged' fired
│  ├─ All pages receive event
│  ├─ Each page calls $translate.use('en')
│  ├─ Loads common_en.json + page1_en.json
│  ├─ Merges new translations
│  └─ Page updates to English INSTANTLY
│
└─ User Navigates to Page2
   ├─ Page2App initializes
   ├─ Checks localStorage → 'en' (persisted!)
   ├─ Loads common_en.json + page2_en.json
   └─ Page2 displays in English automatically
```

---

This is how the entire translation system works! 🎉
