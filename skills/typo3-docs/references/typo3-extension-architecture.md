# TYPO3 Extension Architecture Reference

Extension file inventory annotated for **documentation extraction weighting**
(this skill's own model). **Canonical source for the extension file structure
itself (wins on conflict — see `canonical-sources.md`):**
[Core API: Files and locations](https://docs.typo3.org/m/typo3/reference-coreapi/main/en-us/ExtensionArchitecture/FileStructure/Index.html)
`[upstream]`.

The inventory below is **not exhaustive** — it lists only the files this
skill's extraction pipeline weighs. For the complete, current inventory
(incl. `ext_tables_static+adt.sql`, `ext_typoscript_*.typoscript`,
`Configuration/Fluid/`, `ContentSecurityPolicies.php`,
`RequestMiddlewares.php`, `page.tsconfig`/`user.tsconfig`) read the upstream
page. The Priority/Extract/Map/Weight annotations are `[heuristic]`
(skill-owned extraction model, not a TYPO3 statement).

## File Structure Hierarchy

### 🔴 Required Files (High Priority)

**composer.json** - Composer configuration
- **Documentation Priority:** HIGH
- **Extract:** Package name, description, dependencies, autoload configuration
- **Map to RST:** Introduction/Index.rst (overview), Installation requirements
- **Weight:** Critical for dependency documentation

**ext_emconf.php** - Extension metadata
- **Documentation Priority:** HIGH
- **Extract:** Title, description, version, author, constraints
- **Map to RST:** Introduction/Index.rst, guides.xml (or Settings.cfg)
- **Weight:** Essential metadata, version constraints

**Index.rst** (in Documentation/)
- **Documentation Priority:** CRITICAL
- **Required:** Main documentation entry point
- **Must Exist:** For TYPO3 Intercept deployment

**guides.xml** (in Documentation/) - Modern, Preferred
- **Documentation Priority:** CRITICAL
- **Required:** Documentation build configuration (PHP-based rendering)
- **Must Exist:** For TYPO3 Intercept deployment
- **Note:** Modern format, preferred over Settings.cfg

**Settings.cfg** (in Documentation/) - Legacy
- **Documentation Priority:** CRITICAL (if guides.xml not present)
- **Required:** Documentation build configuration (Sphinx-based)
- **Note:** Legacy format, migrate to guides.xml for modern rendering

### 🟡 Core Structure Files (Medium-High Priority)

**ext_localconf.php** - Runtime configuration
- **Documentation Priority:** MEDIUM-HIGH
- **Extract:** Plugin registrations, hooks, service configurations
- **Map to RST:** Integration guides, Developer/Configuration.rst
- **Weight:** Important for integration documentation

**ext_tables.php** - Backend configuration — **deprecated upstream**: the
Core API marks it "(Deprecated)"; modern extensions register backend modules
and TCA via `Configuration/` instead. When documenting an extension that still
ships one, note the migration.
- **Documentation Priority:** MEDIUM
- **Extract:** Backend module registrations, permissions
- **Map to RST:** Developer/Backend.rst
- **Weight:** Backend-specific documentation

**ext_tables.sql** - Database schema
- **Documentation Priority:** MEDIUM
- **Extract:** Table structures, field definitions
- **Map to RST:** Developer/Database.rst, API/DataModel.rst
- **Weight:** Important for database documentation

**ext_conf_template.txt** - Extension configuration template
- **Documentation Priority:** HIGH
- **Extract:** All configuration options, types, defaults, security warnings
- **Map to RST:** Integration/Configuration.rst (confval directives)
- **Weight:** Critical - direct user-facing configuration

## Directory Structure Weights

### Classes/ (Weight: HIGH)

**Purpose:** PHP source code following PSR-4 autoloading

**Priority Hierarchy:**

1. **Classes/Controller/** (Weight: HIGH)
   - **Documentation Priority:** HIGH
   - **Extract:** Action methods, parameters, return types
   - **Map to RST:** API/Controllers/, Developer/Plugins.rst
   - **Pattern:** MVC controllers extending `ActionController`

2. **Classes/Domain/Model/** (Weight: HIGH)
   - **Documentation Priority:** HIGH
   - **Extract:** Entity properties, getters/setters, relationships
   - **Map to RST:** API/Models/, Developer/DataModel.rst
   - **Pattern:** Extbase domain models

3. **Classes/Domain/Repository/** (Weight: MEDIUM-HIGH)
   - **Documentation Priority:** MEDIUM-HIGH
   - **Extract:** Query methods, custom finders
   - **Map to RST:** API/Repositories/, Developer/DataAccess.rst
   - **Pattern:** Extends `\TYPO3\CMS\Extbase\Persistence\Repository`

4. **Classes/ViewHelpers/** (Weight: MEDIUM)
   - **Documentation Priority:** MEDIUM
   - **Extract:** ViewHelper arguments, usage examples
   - **Map to RST:** Developer/ViewHelpers.rst
   - **Pattern:** Custom Fluid ViewHelpers

5. **Classes/Utility/** (Weight: MEDIUM)
   - **Documentation Priority:** MEDIUM
   - **Extract:** Utility methods, static helpers
   - **Map to RST:** API/Utilities/
   - **Pattern:** Static helper classes

6. **Classes/Service/** (Weight: MEDIUM-HIGH)
   - **Documentation Priority:** MEDIUM-HIGH
   - **Extract:** Service methods, dependencies
   - **Map to RST:** API/Services/
   - **Pattern:** Business logic services

### Configuration/ (Weight: VERY HIGH)

**Purpose:** All TYPO3 configuration files

**Priority Hierarchy:**

1. **Configuration/TCA/** (Weight: VERY HIGH)
   - **Documentation Priority:** VERY HIGH
   - **Extract:** Table definitions, field configurations, relationships
   - **Map to RST:** Developer/DataModel.rst, Editor/Fields.rst
   - **Files:** `<tablename>.php`
   - **Pattern:** Database table configuration arrays

2. **Configuration/TCA/Overrides/** (Weight: HIGH)
   - **Documentation Priority:** HIGH
   - **Extract:** Field additions, modifications to core tables
   - **Map to RST:** Integration/CoreExtensions.rst
   - **Files:** `<tablename>.php`
   - **Pattern:** TCA modifications

3. **Configuration/TypoScript/** (Weight: HIGH)
   - **Documentation Priority:** HIGH
   - **Extract:** Constants, setup, plugin configurations
   - **Map to RST:** Configuration/TypoScript.rst
   - **Files:** `constants.typoscript`, `setup.typoscript`
   - **Pattern:** TypoScript configuration

4. **Configuration/Sets/** (Weight: HIGH)
   - **Documentation Priority:** HIGH
   - **Extract:** Site set configurations, settings definitions
   - **Map to RST:** Configuration/SiteSets.rst
   - **Files:** `config.yaml`, `settings.definitions.yaml`, `setup.typoscript`
   - **Pattern:** Modern configuration approach (TYPO3 v13+)

5. **Configuration/TsConfig/** (Weight: MEDIUM-HIGH)
   - **Documentation Priority:** MEDIUM-HIGH
   - **Extract:** Page TSconfig, User TSconfig
   - **Map to RST:** Editor/PageTSconfig.rst, Editor/UserTSconfig.rst
   - **Subdirs:** `Page/`, `User/`
   - **Files:** `*.tsconfig`

6. **Configuration/Backend/** (Weight: MEDIUM)
   - **Documentation Priority:** MEDIUM
   - **Extract:** Backend routes, modules, AJAX routes
   - **Map to RST:** Developer/Backend.rst
   - **Files:** `Routes.php`, `Modules.php`, `AjaxRoutes.php`

7. **Configuration/Services.yaml** (Weight: HIGH)
   - **Documentation Priority:** HIGH
   - **Extract:** DI configuration, event listeners, console commands
   - **Map to RST:** Developer/DependencyInjection.rst, Developer/Events.rst
   - **Pattern:** Symfony-style service configuration

8. **Configuration/Extbase/Persistence/Classes.php** (Weight: MEDIUM)
   - **Documentation Priority:** MEDIUM
   - **Extract:** Model-to-table mappings
   - **Map to RST:** Developer/Persistence.rst

9. **Configuration/Icons.php** (Weight: LOW)
   - **Documentation Priority:** LOW
   - **Extract:** Icon identifiers
   - **Map to RST:** Developer/Icons.rst (if comprehensive)

### Resources/ (Weight: MEDIUM)

**Purpose:** Asset files and templates

**Priority Hierarchy:**

1. **Resources/Private/Language/** (Weight: MEDIUM-HIGH)
   - **Documentation Priority:** MEDIUM
   - **Extract:** Translation keys (for reference)
   - **Map to RST:** Developer/Localization.rst
   - **Files:** `*.xlf` (XLIFF format)
   - **Note:** Extract labels for API documentation context

2. **Resources/Private/Templates/** (Weight: MEDIUM)
   - **Documentation Priority:** MEDIUM
   - **Extract:** Template structure (for developer reference)
   - **Map to RST:** Developer/Templating.rst
   - **Files:** `[ControllerName]/[ActionName].html`
   - **Note:** Document template variables and ViewHelpers used

3. **Resources/Private/Layouts/** (Weight: LOW-MEDIUM)
   - **Documentation Priority:** LOW
   - **Extract:** Layout structure
   - **Files:** `*.html`

4. **Resources/Private/Partials/** (Weight: LOW-MEDIUM)
   - **Documentation Priority:** LOW
   - **Extract:** Reusable template fragments
   - **Files:** `*.html`

5. **Resources/Public/** (Weight: LOW)
   - **Documentation Priority:** LOW
   - **Extract:** Public asset information (if relevant)
   - **Subdirs:** `CSS/`, `JavaScript/`, `Icons/`, `Images/`
   - **Note:** Usually not documented in detail

### Documentation/ (Weight: CRITICAL)

**Purpose:** Official RST documentation

**Required Files:**
- `Index.rst` - Main entry point
- `guides.xml` - Build configuration (modern, preferred)
- `Settings.cfg` - Build configuration (legacy, if guides.xml not present)

**Common Structure:**
- `Introduction/` - Overview, features, screenshots
- `Installation/` - Installation and upgrade
- `Configuration/` - TypoScript, extension settings
- `Integration/` - Integration with other extensions
- `Editor/` - User guide for editors
- `Developer/` - Developer documentation
- `API/` - PHP API reference
- `Troubleshooting/` - Common issues

**Priority:** CRITICAL - This is the primary output target for extraction

### Tests/ (Weight: LOW)

**Purpose:** Unit, functional, and acceptance tests

**Documentation Priority:** LOW
- Extract test class names for coverage documentation
- Generally not documented in user-facing docs
- May reference in Developer/Testing.rst if test examples provided

**Structure:**
- `Tests/Unit/` - Unit tests
- `Tests/Functional/` - Functional tests
- `Tests/Acceptance/` - Acceptance tests (Codeception)

## Extraction Weight Matrix

### Primary Sources (Extract First)

```
Priority 1 - CRITICAL (Must Document):
├─ ext_emconf.php → Extension metadata
├─ ext_conf_template.txt → User configuration
├─ composer.json → Dependencies
└─ Configuration/TCA/*.php → Data model

Priority 2 - HIGH (Should Document):
├─ Classes/Controller/ → Controllers/Actions
├─ Classes/Domain/Model/ → Domain entities
├─ Classes/Service/ → Business logic
├─ Configuration/TypoScript/ → TypoScript config
├─ Configuration/Sets/ → Site sets (v13+)
└─ ext_localconf.php → Runtime registration

Priority 3 - MEDIUM (Consider Documenting):
├─ Classes/Domain/Repository/ → Data access
├─ Classes/ViewHelpers/ → Custom ViewHelpers
├─ Configuration/Backend/ → Backend modules
├─ Configuration/TsConfig/ → TSconfig
├─ Configuration/Services.yaml → DI/Events
└─ Resources/Private/Language/ → Translation context
```

### Secondary Sources (Extract If Needed)

```
Priority 4 - MEDIUM-LOW:
├─ Classes/Utility/ → Utility functions
├─ ext_tables.php → Backend config
├─ ext_tables.sql → Database schema
└─ Configuration/TCA/Overrides/ → Core extensions

Priority 5 - LOW:
├─ Resources/Private/Templates/ → Template structure
├─ Resources/Public/ → Public assets
├─ Tests/ → Test coverage
└─ Configuration/Icons.php → Icon registry
```

## Documentation Mapping Strategy

### Extension Metadata → Introduction

**Source:** `ext_emconf.php`, `composer.json`, `README.md`

**Target:** `Documentation/Introduction/Index.rst`

**Extract:**
- Extension title → Main heading
- Description → First paragraph
- Version → Version marker
- Author → Credits section
- Constraints → Requirements section

**Example Mapping:**
```
ext_emconf.php:
  'title' => 'CKEditor Image Support'
  'version' => '13.1.0'
  'constraints' => ['typo3' => '12.4-13.5']

→ Introduction/Index.rst:
  ========================
  CKEditor Image Support
  ========================

  :Version: 13.1.0
  :Language: en

  Requirements
  ------------
  - TYPO3: 12.4 - 13.5
```

### Configuration Options → Integration/Configuration

**Source:** `ext_conf_template.txt`

**Target:** `Documentation/Integration/Configuration.rst`

**Extract Pattern:**
```
# cat=category; type=boolean; label=Label: Description
settingName = defaultValue

→ .. confval:: settingName
     :type: boolean
     :Default: defaultValue
     :Path: $GLOBALS['TYPO3_CONF_VARS']['EXTENSIONS']['ext_key']['settingName']

     Description text here
```

**Security Warnings:** Extract and map to `.. warning::` directive

### PHP Classes → API Documentation

**Source:** `Classes/**/*.php`

**Target:** `Documentation/API/[ClassName].rst`

**Mapping by Type:**

**Controllers:**
```php
Classes/Controller/UserController.php

→ API/UserController.rst

  .. php:class:: UserController

     User management controller

     .. php:method:: listAction(): ResponseInterface
```

**Models:**
```php
Classes/Domain/Model/User.php

→ API/User.rst

  .. php:class:: User

     User domain model

     .. php:attr:: username
        :type: string
```

**Repositories:**
```php
Classes/Domain/Repository/UserRepository.php

→ API/UserRepository.rst

  .. php:class:: UserRepository

     User data repository

     .. php:method:: findByEmail(string $email): ?User
```

### TCA Configuration → Developer/DataModel

**Source:** `Configuration/TCA/*.php`

**Target:** `Documentation/Developer/DataModel.rst`

**Extract:**
- Table name → Section heading
- ctrl['title'] → Table title
- columns → Field documentation

**Example:**
```php
Configuration/TCA/tx_myext_domain_model_user.php:
  'ctrl' => ['title' => 'User']
  'columns' => [
    'username' => [...],
    'email' => [...]
  ]

→ Developer/DataModel.rst:

  Users Table
  ===========

  Database table: tx_myext_domain_model_user

  Fields
  ------

  username
    User login name

  email
    User email address
```

### TypoScript → Configuration/TypoScript

**Source:** `Configuration/TypoScript/*.typoscript`

**Target:** `Documentation/Configuration/TypoScript.rst`

**Extract:**
- Constants → Configuration reference
- Setup → Implementation examples

## Quality Weighting Algorithm

### Documentation Coverage Score

```
Score = (P1_documented / P1_total) * 0.5 +
        (P2_documented / P2_total) * 0.3 +
        (P3_documented / P3_total) * 0.15 +
        (P4_documented / P4_total) * 0.05

Where:
  P1 = Priority 1 (CRITICAL) items
  P2 = Priority 2 (HIGH) items
  P3 = Priority 3 (MEDIUM) items
  P4 = Priority 4+ (LOW) items
```

### Gap Analysis Priority

```
Priority = BaseWeight * Severity * UserImpact

BaseWeight (from file structure):
  ext_conf_template.txt config = 10
  Controllers = 9
  Models = 9
  TCA = 8
  ext_emconf.php = 8
  Services = 7
  Repositories = 6
  ViewHelpers = 5
  Utilities = 4

Severity:
  Missing completely = 3
  Outdated (wrong defaults) = 2
  Incomplete (missing examples) = 1

UserImpact:
  User-facing (config, editor features) = 3
  Integrator-facing (TypoScript, TSconfig) = 2
  Developer-facing (API) = 1
```

### Example Calculation

```
Missing confval for "fetchExternalImages":
  Priority = 10 (ext_conf_template) * 3 (missing) * 3 (user-facing) = 90

Outdated Controller documentation:
  Priority = 9 (controller) * 2 (outdated) * 1 (developer) = 18

Missing Utility documentation:
  Priority = 4 (utility) * 3 (missing) * 1 (developer) = 12
```

**Action:** Document in priority order: 90 → 18 → 12

## Structure Checklist `[heuristic]`

What this skill expects before documenting an extension (upstream does not
mandate a fixed file set — see the Core API page for what each file does):

**Composer-Mode Installation:**
- ✅ `composer.json` with `"type": "typo3-cms-extension"`
- ✅ PSR-4 autoload configuration
- ✅ `Documentation/Index.rst`
- ✅ `Documentation/guides.xml` (modern) OR `Documentation/Settings.cfg` (legacy)

**Classic-Mode Installation:**
- ✅ `ext_emconf.php`
- ✅ `Documentation/Index.rst`
- ✅ `Documentation/guides.xml` (modern) OR `Documentation/Settings.cfg` (legacy)

### `ext_*` Files `[upstream]`

The reserved `ext_*` names and their meaning are defined by the Core API page
linked in the header (`ext_emconf.php`, `ext_localconf.php`, `ext_tables.php`
(deprecated), `ext_tables.sql`, `ext_tables_static+adt.sql`,
`ext_conf_template.txt`, `ext_typoscript_constants.typoscript`,
`ext_typoscript_setup.typoscript`). Upstream states no prohibition on other
`ext_*` file names — but an unknown `ext_*` file has no TYPO3 semantics, so
treat one as a smell worth documenting, not as forbidden.

## Best Practices for Extraction

1. **Follow Official Structure:** Extract based on official TYPO3 architecture
2. **Weight by Location:** Use file location to determine documentation priority
3. **Respect Conventions:** Map to RST sections based on TYPO3 conventions
4. **Security First:** Extract and highlight security warnings from configs
5. **Version Awareness:** Track version-specific features from ext_emconf.php
6. **Dependency Mapping:** Use composer.json and constraints for requirements
7. **Complete Coverage:** Prioritize user-facing config, controllers, models
8. **Context Awareness:** Understand file purpose from directory structure

## Resources

- **Official Structure:** https://docs.typo3.org/m/typo3/reference-coreapi/main/en-us/ExtensionArchitecture/FileStructure/
- **TCA Reference:** https://docs.typo3.org/m/typo3/reference-tca/
- **TypoScript Reference:** https://docs.typo3.org/m/typo3/reference-typoscript/
- **Extbase/Fluid:** https://docs.typo3.org/m/typo3/book-extbasefluid/
