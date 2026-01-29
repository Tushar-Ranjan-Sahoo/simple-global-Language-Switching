# Translation System - How It Works

## 📚 Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Core Components](#core-components)
4. [Translation Flow](#translation-flow)
5. [How Pages Are Affected](#how-pages-are-affected)
6. [Code Walkthrough](#code-walkthrough)
7. [Examples](#examples)

---

## Overview

The translation system uses a **global event-driven architecture** where:
- One dropdown in the header controls ALL pages
- Language preference is stored in browser localStorage
- Pages automatically sync when language changes
- Each page can have its own translation file + common translations

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Browser Window                           │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  header.jsp (HeaderApp)                              │  │
│  │  ┌──────────────────────────────────────────────┐    │  │
│  │  │ Language Dropdown                            │    │  │
│  │  │ [English ▼] [Hindi] [Marathi]                │    │  │
│  │  └──────────────────────────────────────────────┘    │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  page1.jsp (Page1App)                                │  │
│  │  {{ 'PAGE1_HEADING' | translate }}                  │  │
│  │  {{ 'WELCOME_MESSAGE' | translate }}                 │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  page2.jsp (Page2App)                                │  │
│  │  {{ 'PAGE2_HEADING' | translate }}                  │  │
│  │  {{ 'WELCOME_MESSAGE' | translate }}                 │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  global-translation.js (Global Helper)              │  │
│  │  - GlobalTranslation object                          │  │
│  │  - Event system                                      │  │
│  │  - localStorage management                           │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Core Components

### 1. **GlobalTranslation Object** (`global-translation.js`)

```javascript
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
```

**Purpose**: Central storage for current language and event dispatcher.

**Key Features**:
- Stores language in `localStorage` (persists across sessions)
- Fires `globalLanguageChanged` event when language changes
- All pages listen to this event

---

### 2. **setupPageTranslation() Function**

```javascript
window.setupPageTranslation = function(appModule, pageTranslationFile) {
    var module = angular.module(appModule, ['pascalprecht.translate']);
    
    module.config(['$translateProvider', function($translateProvider) {
        window.initTranslation($translateProvider, pageTranslationFile);
    }]);
    
    return module;
};
```

**Purpose**: One-line setup for each page's Angular module.

**What it does**:
1. Creates/gets Angular module with `pascalprecht.translate` dependency
2. Configures translation provider
3. Sets up custom loader for page-specific + common translations
4. Returns module for chaining

**Usage**:
```javascript
var app = window.setupPageTranslation('Page1App', 'page1');
```

---

### 3. **initTranslation() Function**

```javascript
window.initTranslation = function($translateProvider, pageTranslationFile) {
    var savedLang = window.GlobalTranslation.getCurrentLanguage();
    var contextPath = window.APP_CONTEXT_PATH || '';
    var i18nPath = contextPath + '/i18n/';
    
    if (pageTranslationFile) {
        // Custom loader that loads TWO files: common + page-specific
        $translateProvider.useLoader('$translate', ['$q', '$http', function($q, $http) {
            return function(options) {
                var lang = options.key || window.GlobalTranslation.getCurrentLanguage();
                
                var loadFile = function(file) {
                    return $http.get(i18nPath + file + '_' + lang + '.json')
                        .then(function(response) { return response.data; },
                              function() { return {}; });
                };
                
                // Load BOTH files and merge
                return $q.all([
                    loadFile('common'),           // common_en.json
                    loadFile(pageTranslationFile) // page1_en.json
                ]).then(function(results) {
                    // Merge: page-specific overrides common
                    var merged = {};
                    angular.extend(merged, results[0]); // common first
                    angular.extend(merged, results[1]); // page overrides
                    return merged;
                });
            };
        }]);
    }
    
    $translateProvider.preferredLanguage(savedLang);
    $translateProvider.useSanitizeValueStrategy('escape');
};
```

**Purpose**: Configures how translations are loaded.

**Key Points**:
- Loads **TWO JSON files**: `common_XX.json` + `pageX_XX.json`
- Merges them (page-specific keys override common keys)
- Uses saved language from localStorage
- Handles missing files gracefully (returns empty object)

---

### 4. **syncTranslation() Function**

```javascript
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
```

**Purpose**: Syncs page with global language changes.

**What it does**:
1. Sets current language on page load
2. Listens for `globalLanguageChanged` event
3. When event fires, updates `$translate` service
4. Calls `$scope.$apply()` to update Angular bindings

**Critical**: This is what makes ALL pages update when dropdown changes!

---

## Translation Flow

### Flow 1: Page Initial Load

```
1. User opens page1.jsp
   ↓
2. Browser loads HTML
   ↓
3. header.jsp includes:
   - global-translation.js
   - AngularJS
   - angular-translate
   ↓
4. Page1App module initializes
   ↓
5. setupPageTranslation('Page1App', 'page1') called
   ↓
6. initTranslation() configures loader
   ↓
7. Loader fetches:
   - common_en.json (or saved language)
   - page1_en.json (or saved language)
   ↓
8. Files merged into single translation object
   ↓
9. Angular renders page with translations
   ↓
10. {{ 'KEY' | translate }} displays translated text
```

### Flow 2: Language Change (User Clicks Dropdown)

```
1. User clicks dropdown in header
   ↓
2. Selects "Hindi" (hi)
   ↓
3. HeaderController.changeLang('hi') called
   ↓
4. GlobalTranslation.changeLanguage('hi') called
   ↓
5. localStorage.setItem('selectedLanguage', 'hi')
   ↓
6. window.dispatchEvent('globalLanguageChanged', { detail: 'hi' })
   ↓
7. Event fires across ENTIRE browser window
   ↓
8. ALL pages listening via syncTranslation() receive event
   ↓
9. Each page's syncTranslation() handler:
   - Calls $translate.use('hi')
   - Calls $scope.$apply()
   ↓
10. Angular re-evaluates ALL {{ 'KEY' | translate }} expressions
   ↓
11. Loader fetches NEW files:
    - common_hi.json
    - page1_hi.json (or page2_hi.json)
   ↓
12. Page updates with Hindi translations
   ↓
13. User navigates to page2 → Language persists (from localStorage)
```

### Flow 3: Page Navigation

```
1. User on page1 (language: Hindi)
   ↓
2. Clicks link to page2
   ↓
3. Browser loads page2.jsp
   ↓
4. Page2App initializes
   ↓
5. setupPageTranslation('Page2App', 'page2') called
   ↓
6. initTranslation() reads from localStorage
   ↓
7. Finds saved language: 'hi'
   ↓
8. Loads:
   - common_hi.json
   - page2_hi.json
   ↓
9. Page2 displays in Hindi automatically
   ↓
10. No need to change language again!
```

---

## How Pages Are Affected

### When Language Changes

**ALL pages** that have:
1. Included `header.jsp` (has the dropdown)
2. Called `window.syncTranslation($scope, $translate)` in controller

**Will automatically**:
- Update all `{{ 'KEY' | translate }}` expressions
- Reload translation files for new language
- Re-render with new translations
- Maintain state (no page reload needed)

### Example: User Changes Language

**Before (English)**:
```html
<h1>Page 1 Heading</h1>
<p>Welcome to our application!</p>
<button>Submit</button>
```

**User clicks dropdown → Selects "Hindi"**

**After (Hindi)** - **INSTANTLY**:
```html
<h1>पृष्ठ 1 शीर्षक</h1>
<p>हमारे एप्लिकेशन में आपका स्वागत है!</p>
<button>जमा करें</button>
```

**No page reload!** Angular updates bindings automatically.

---

## Code Walkthrough

### Step-by-Step: How Page1 Works

#### 1. **HTML Structure** (`page1.jsp`)

```jsp
<html ng-app="Page1App">
<head>
    <jsp:include page="header.jsp"/>  <!-- Loads scripts + dropdown -->
</head>
<body>
    <div ng-controller="Page1Controller">
        <h1>{{ 'PAGE1_HEADING' | translate }}</h1>
        <p>{{ 'WELCOME_MESSAGE' | translate }}</p>
    </div>
    
    <script>
        var app = window.setupPageTranslation('Page1App', 'page1');
        
        app.controller('Page1Controller', ['$scope', '$translate', function($scope, $translate) {
            window.syncTranslation($scope, $translate);
        }]);
    </script>
</body>
</html>
```

**What happens**:
- `ng-app="Page1App"` tells Angular to bootstrap Page1App module
- `{{ 'PAGE1_HEADING' | translate }}` is an Angular expression with translate filter
- `setupPageTranslation()` configures translation system
- `syncTranslation()` connects page to global language changes

#### 2. **Translation Files Loaded**

When page loads with language 'en':

**File 1: `common_en.json`**
```json
{
  "WELCOME_MESSAGE": "Welcome to our application!",
  "BUTTON_SUBMIT": "Submit",
  "BUTTON_CANCEL": "Cancel"
}
```

**File 2: `page1_en.json`**
```json
{
  "PAGE1_HEADING": "Page 1 Heading",
  "PAGE1_TEXT": "This is the content for Page 1 in English."
}
```

**Merged Result** (what Angular sees):
```json
{
  "WELCOME_MESSAGE": "Welcome to our application!",
  "BUTTON_SUBMIT": "Submit",
  "BUTTON_CANCEL": "Cancel",
  "PAGE1_HEADING": "Page 1 Heading",
  "PAGE1_TEXT": "This is the content for Page 1 in English."
}
```

#### 3. **Angular Rendering**

```html
{{ 'PAGE1_HEADING' | translate }}
```

**Angular Process**:
1. Evaluates `'PAGE1_HEADING'` → `"PAGE1_HEADING"`
2. Applies `translate` filter
3. Filter calls `$translate.instant('PAGE1_HEADING')`
4. Looks up in merged translation object
5. Returns `"Page 1 Heading"`
6. Displays in HTML

#### 4. **Language Change Event**

When user selects "Hindi":

```javascript
// In header.jsp HeaderController
$scope.changeLang = function(lang) {
    GlobalTranslation.changeLanguage(lang);  // Step 1: Save + Fire event
    $translate.use(lang);                    // Step 2: Update header's translate
};

// In global-translation.js
changeLanguage: function(langKey) {
    localStorage.setItem('selectedLanguage', langKey);  // Save
    this.currentLanguage = langKey;
    window.dispatchEvent(new CustomEvent('globalLanguageChanged', { detail: langKey }));  // Fire event
}

// In page1.jsp Page1Controller (via syncTranslation)
window.addEventListener('globalLanguageChanged', function(event) {
    $translate.use(event.detail);  // Change language
    $scope.$apply();               // Update bindings
});
```

**Result**: All `{{ 'KEY' | translate }}` re-evaluate with new language!

---

## Examples

### Example 1: Simple Page

**page3.jsp**:
```jsp
<html ng-app="Page3App">
<head>
    <jsp:include page="header.jsp"/>
</head>
<body>
    <div ng-controller="Page3Controller">
        <h1>{{ 'TITLE' | translate }}</h1>
        <p>{{ 'DESCRIPTION' | translate }}</p>
    </div>
    
    <script>
        var app = window.setupPageTranslation('Page3App', 'page3');
        app.controller('Page3Controller', ['$scope', '$translate', function($scope, $translate) {
            window.syncTranslation($scope, $translate);
        }]);
    </script>
</body>
</html>
```

**page3_en.json**:
```json
{
  "TITLE": "Page 3",
  "DESCRIPTION": "This is page 3"
}
```

**Result**: Page3 automatically gets translation support!

### Example 2: Page with Common + Specific Keys

**page4_en.json**:
```json
{
  "PAGE4_SPECIFIC": "This is only on page 4"
}
```

**common_en.json** (already exists):
```json
{
  "WELCOME_MESSAGE": "Welcome!",
  "BUTTON_SAVE": "Save"
}
```

**page4.jsp**:
```html
<h1>{{ 'PAGE4_SPECIFIC' | translate }}</h1>
<p>{{ 'WELCOME_MESSAGE' | translate }}</p>
<button>{{ 'BUTTON_SAVE' | translate }}</button>
```

**Result**: 
- `PAGE4_SPECIFIC` comes from `page4_en.json`
- `WELCOME_MESSAGE` and `BUTTON_SAVE` come from `common_en.json`
- All work together seamlessly!

### Example 3: Override Common Key

**common_en.json**:
```json
{
  "BUTTON_TEXT": "Click Me"
}
```

**page5_en.json**:
```json
{
  "BUTTON_TEXT": "Page 5 Button"  // Overrides common!
}
```

**Result**: Page5 shows "Page 5 Button" instead of "Click Me" because page-specific overrides common.

---

## Key Concepts

### 1. **Event-Driven Architecture**
- Header fires `globalLanguageChanged` event
- All pages listen via `syncTranslation()`
- No direct coupling between pages

### 2. **Merged Translations**
- Common translations: Shared across all pages
- Page-specific: Unique to each page
- Merging: Page-specific overrides common (same key)

### 3. **Persistent State**
- Language stored in `localStorage`
- Survives page refreshes
- Survives browser restarts
- Survives navigation between pages

### 4. **Lazy Loading**
- Translation files loaded on-demand
- Only when language changes
- Cached by browser (HTTP cache)

### 5. **Angular Integration**
- Uses `angular-translate` library
- `{{ 'KEY' | translate }}` filter syntax
- Automatic re-evaluation on language change
- No manual DOM manipulation needed

---

## Summary

**How Translation Works**:
1. Each page calls `setupPageTranslation()` → Configures loader
2. Loader fetches `common_XX.json` + `pageX_XX.json` → Merges them
3. Angular uses merged object → Renders `{{ 'KEY' | translate }}`
4. User changes language → `GlobalTranslation.changeLanguage()` fires event
5. All pages receive event → Update via `syncTranslation()`
6. Angular re-renders → All text updates instantly

**How Pages Are Affected**:
- ✅ All pages update when dropdown changes
- ✅ Language persists across navigation
- ✅ Each page can have unique translations
- ✅ Common translations shared automatically
- ✅ No code duplication needed

**The Magic**: The `globalLanguageChanged` event + `syncTranslation()` function connects all pages together!
