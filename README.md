# Simple Global Language Switching

A Spring MVC + AngularJS application with global language translation support. Features a language dropdown in the header that controls translations across all pages with minimal setup required.

## 📖 Documentation

- **[TRANSLATION_WORKFLOW.md](TRANSLATION_WORKFLOW.md)** - Complete explanation of how the translation system works
- **[CODE_EXECUTION_FLOW.md](CODE_EXECUTION_FLOW.md)** - Step-by-step code execution flow with examples

## 🌟 Features

- **Global Language Control**: Single dropdown in header controls all pages
- **Page-Specific Translations**: Each page can have its own translation JSON files
- **Common Translations**: Shared translations in common files
- **Persistent Language**: Language preference saved in localStorage
- **Minimal Setup**: Only 2 lines of code needed per page
- **Multiple Angular Apps**: Works with different `ng-app` modules on different pages

## 📋 Prerequisites

- Java JDK 1.8 or higher
- Apache Tomcat 7 or higher
- Eclipse IDE (for Eclipse setup)
- Maven 3.x (optional, for building with Maven)

## 🚀 How to Run in Eclipse

### Step 1: Import Project into Eclipse

1. **Open Eclipse IDE**
2. **File → Import → Existing Projects into Workspace**
3. Select the project folder: `g translation`
4. Check "Copy projects into workspace" (optional)
5. Click **Finish**

### Step 2: Configure Project as Dynamic Web Project

1. **Right-click project → Properties**
2. **Project Facets**
3. Enable:
   - ✅ Java (1.8 or higher)
   - ✅ Dynamic Web Module (3.0 or higher)
   - ✅ JavaScript (optional)
4. Click **Apply and Close**

### Step 3: Configure Build Path

1. **Right-click project → Build Path → Configure Build Path**
2. **Libraries tab**
3. If using Maven:
   - Right-click project → **Maven → Update Project**
   - Check "Force Update of Snapshots/Releases"
   - Click **OK**
4. If not using Maven, manually add Spring JARs:
   - Click **Add External JARs**
   - Add Spring Framework JARs (see Manual Setup below)

### Step 4: Add Tomcat Server

1. **Window → Show View → Servers** (or right-click in Servers view)
2. **Right-click → New → Server**
3. Select **Apache → Tomcat v7.0 Server**
4. Click **Next**
5. Browse to your Tomcat installation directory
6. Click **Finish**

### Step 5: Deploy and Run

1. **Right-click project → Run As → Run on Server**
2. Select your Tomcat server
3. Click **Finish**
4. Eclipse will:
   - Start Tomcat automatically
   - Deploy your application
   - Open browser to: `http://localhost:8080/global-translation/`

### Step 6: Access Application

- **Home/Page1**: `http://localhost:8080/global-translation/` or `/page1`
- **Page2**: `http://localhost:8080/global-translation/page2`
- **Translation Files**: `http://localhost:8080/global-translation/i18n/common_en.json`

## 📁 Project Structure

```
g translation/
├── WebContent/
│   ├── WEB-INF/
│   │   ├── web.xml                    # Servlet configuration
│   │   ├── dispatcher-servlet.xml     # Spring MVC configuration
│   │   └── views/
│   │       ├── header.jsp             # Header with language dropdown
│   │       ├── footer.jsp             # Footer
│   │       ├── page1.jsp              # Example page 1
│   │       └── page2.jsp              # Example page 2
│   ├── js/
│   │   └── global-translation.js      # Global translation helper
│   ├── i18n/
│   │   ├── common_en.json             # Common English translations
│   │   ├── common_hi.json             # Common Hindi translations
│   │   ├── common_mr.json             # Common Marathi translations
│   │   ├── page1_en.json              # Page1 English translations
│   │   ├── page1_hi.json              # Page1 Hindi translations
│   │   ├── page1_mr.json              # Page1 Marathi translations
│   │   ├── page2_en.json              # Page2 English translations
│   │   ├── page2_hi.json              # Page2 Hindi translations
│   │   └── page2_mr.json              # Page2 Marathi translations
│   └── index.html                     # Redirect page
├── src/
│   └── main/
│       └── java/
│           └── com/
│               └── example/
│                   └── controller/
│                       └── PageController.java  # Spring MVC Controller
└── pom.xml                            # Maven configuration
```

## 🔄 Project Workflow

### 1. **Request Flow**

```
User Request → Tomcat → web.xml → DispatcherServlet → 
PageController → View Resolver → JSP Page → Browser
```

### 2. **Translation Flow**

```
Page Loads → header.jsp includes scripts → 
AngularJS initializes → global-translation.js loads → 
Loads common_*.json + pageX_*.json → Merges translations → 
Displays in page using {{ 'KEY' | translate }}
```

### 3. **Language Switching Flow**

```
User clicks dropdown → HeaderController.changeLang() → 
GlobalTranslation.changeLanguage() → 
Saves to localStorage → 
Fires 'globalLanguageChanged' event → 
All pages listening update via syncTranslation() → 
All {{ 'KEY' | translate }} update automatically
```

### 4. **Page-Specific Translation Loading**

1. **Page specifies translation file**: `window.setupPageTranslation('Page1App', 'page1')`
2. **Custom loader loads two files**:
   - `common_en.json` (or `common_hi.json`, `common_mr.json`)
   - `page1_en.json` (or `page1_hi.json`, `page1_mr.json`)
3. **Files are merged**: Page-specific keys override common keys
4. **Result**: Combined translations available to page

### 5. **Persistence Flow**

```
Language selected → localStorage.setItem('selectedLanguage', 'hi') → 
Page refresh → localStorage.getItem('selectedLanguage') → 
Loads saved language automatically
```

## 💻 How to Add a New Page

### Step 1: Create JSP File

Create `WebContent/WEB-INF/views/yourpage.jsp`:

```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en" ng-app="YourPageApp">
<head>
    <meta charset="UTF-8">
    <title>Your Page</title>
    <jsp:include page="header.jsp"/>
</head>
<body>
    <div ng-controller="YourPageController">
        <h1>{{ 'YOUR_PAGE_HEADING' | translate }}</h1>
        <p>{{ 'YOUR_PAGE_TEXT' | translate }}</p>
    </div>
    
    <jsp:include page="footer.jsp"/>
    
    <script>
        // ONE LINE: Setup translation with your page's JSON file
        var app = window.setupPageTranslation('YourPageApp', 'yourpage');
        
        app.controller('YourPageController', ['$scope', '$translate', function($scope, $translate) {
            // ONE LINE: Sync with global translation
            window.syncTranslation($scope, $translate);
        }]);
    </script>
</body>
</html>
```

### Step 2: Create Translation Files

Create in `WebContent/i18n/`:
- `yourpage_en.json`
- `yourpage_hi.json`
- `yourpage_mr.json`

Example `yourpage_en.json`:
```json
{
  "YOUR_PAGE_HEADING": "Your Page Heading",
  "YOUR_PAGE_TEXT": "Your page content"
}
```

### Step 3: Add Controller Mapping

Add to `PageController.java`:
```java
@RequestMapping("/yourpage")
public String yourpage() {
    return "yourpage";
}
```

That's it! Your page now has translation support.

## 🛠️ Manual Setup (Without Maven)

If you're not using Maven, download and add these JARs to `WebContent/WEB-INF/lib/`:

1. **Spring Framework 5.3.21** (download from https://spring.io/projects/spring-framework):
   - spring-webmvc-5.3.21.jar
   - spring-web-5.3.21.jar
   - spring-context-5.3.21.jar
   - spring-beans-5.3.21.jar
   - spring-core-5.3.21.jar
   - spring-expression-5.3.21.jar

2. **JSTL**:
   - jstl-1.2.jar

3. **Compile Java files**:
   ```bash
   javac -cp "WebContent/WEB-INF/lib/*" -d WebContent/WEB-INF/classes src/main/java/com/example/controller/PageController.java
   ```

## 🧪 Testing

1. **Start Application**: Run on Tomcat server in Eclipse
2. **Open Page1**: Navigate to `http://localhost:8080/global-translation/page1`
3. **Test Language Switch**: 
   - Click dropdown, select "Hindi" or "Marathi"
   - All text should change immediately
4. **Test Persistence**:
   - Refresh page - language should remain
   - Navigate to page2 - language should persist
   - Close browser and reopen - language should still persist
5. **Test Page-Specific Translations**:
   - Each page should show its own content
   - Common translations (like buttons) should be consistent

## 🔧 Troubleshooting

### 404 Error
- ✅ Check if Tomcat is running
- ✅ Verify project is deployed in Servers view
- ✅ Check `web.xml` configuration

### Translation Files Not Loading
- ✅ Verify `i18n` folder is accessible: `http://localhost:8080/global-translation/i18n/common_en.json`
- ✅ Check browser console (F12) for JavaScript errors
- ✅ Verify context path in `header.jsp` is correct

### JSP Not Found
- ✅ Check `dispatcher-servlet.xml` view resolver configuration
- ✅ Verify JSP files are in `WebContent/WEB-INF/views/`

### Spring Controller Not Working
- ✅ Check package name in `dispatcher-servlet.xml` matches controller package
- ✅ Verify Spring JARs are in classpath
- ✅ Check Eclipse Build Path includes all dependencies

### AngularJS Not Working
- ✅ Check browser console for JavaScript errors
- ✅ Verify CDN links in `header.jsp` are accessible
- ✅ Check if `global-translation.js` is loading

## 📝 Key Files Explained

### `global-translation.js`
- Manages global language state
- Provides `setupPageTranslation()` for easy page setup
- Handles loading and merging of common + page-specific translations
- Syncs language changes across all pages

### `header.jsp`
- Contains language dropdown
- Loads all required scripts (AngularJS, angular-translate)
- Sets up context path for translation files
- Includes HeaderApp for dropdown functionality

### `dispatcher-servlet.xml`
- Configures Spring MVC
- Sets up view resolver for JSP files
- Configures static resource mapping for JS, CSS, and JSON files

### `web.xml`
- Configures DispatcherServlet
- Sets up character encoding filter
- Defines welcome files

## 🌐 Supported Languages

- **English (en)** - Default
- **Hindi (hi)**
- **Marathi (mr)**

To add more languages:
1. Add option to dropdown in `header.jsp`
2. Create translation files: `common_XX.json`, `page1_XX.json`, etc.
3. No code changes needed!

## 📄 License

This project is open source and available for use.

## 👤 Author

Tushar Ranjan Sahoo

---

**Happy Coding! 🚀**
