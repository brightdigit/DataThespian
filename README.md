# DataThespian

[![](https://img.shields.io/badge/docc-read_documentation-blue)](https://swiftpackageindex.com/brightdigit/DataThespian/documentation)
[![SwiftPM](https://img.shields.io/badge/SPM-Linux%20%7C%20iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-success?logo=swift)](https://swift.org)
[![Twitter](https://img.shields.io/badge/twitter-@brightdigit-blue.svg?style=flat)](http://twitter.com/brightdigit)
![GitHub](https://img.shields.io/github/license/brightdigit/DataThespian)
![GitHub issues](https://img.shields.io/github/issues/brightdigit/DataThespian)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/brightdigit/DataThespian/DataThespian.yml?label=actions&logo=github&?branch=main)

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FDataThespian%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/DataThespian)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FDataThespian%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/DataThespian)

[![Codecov](https://img.shields.io/codecov/c/github/brightdigit/DataThespian)](https://codecov.io/gh/brightdigit/DataThespian)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/brightdigit/DataThespian)](https://www.codefactor.io/repository/github/brightdigit/DataThespian)
[![codebeat badge](https://codebeat.co/badges/63949717-cda3-46c7-b1cb-60a0c2fe9c72)](https://codebeat.co/projects/github-com-brightdigit-DataThespian-main)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/brightdigit/DataThespian)](https://codeclimate.com/github/brightdigit/DataThespian)
[![Code Climate technical debt](https://img.shields.io/codeclimate/tech-debt/brightdigit/DataThespian?label=debt)](https://codeclimate.com/github/brightdigit/DataThespian)
[![Code Climate issues](https://img.shields.io/codeclimate/issues/brightdigit/DataThespian)](https://codeclimate.com/github/brightdigit/DataThespian)

# Table of Contents

* [Introduction](#introduction)
   * [Requirements](#requirements)
   * [Installation](#installation)
   * [Usage](#usage)
      * [Setting up Database](#setting-up-database)
      * [Making Queries](#making-queries)
   * [Documentation](#documentation)
* [License](#license)

# Introduction

DataThespian is [a thread-safe SwiftData implementation that uses the power of ModelActors](https://brightdigit.com/tutorials/swiftdata-modelactor/) to provide an optimized and type-safe database interface. It offers a clean API for common database operations while maintaining concurrency safety and preventing common SwiftData pitfalls.

Key features:
- Thread-safe database operations using ModelActor
- Type-safe query interface with Selectors
- SwiftUI integration via Environment
- Support for monitoring database changes
- Collection synchronization utilities

## Requirements 

**Apple Platforms**

- Xcode 16.0 or later
- Swift 6.0 or later
- iOS 17 / watchOS 10.0 / tvOS 17 / macOS 14 or later deployment targets

**Linux**

- Ubuntu 20.04 or later
- Swift 6.0 or later

## Installation

To integrate **DataThespian** into your app using SPM, specify it in your Package.swift file:

```swift    
let package = Package(
  ...
  dependencies: [
    .package(url: "https://github.com/brightdigit/DataThespian.git", from: "1.0.0")
  ],
  targets: [
      .target(
          name: "YourApps",
          dependencies: [
            .product(name: "DataThespian", package: "DataThespian"), ...
          ]),
      ...
  ]
)
```

## Usage

### Setting up Database

When working with SwiftData, it's crucial to use a single `ModelContext` throughout your app. There are two ways to create your database:

#### Using Built-in ModelActorDatabase

```swift
// Create a database using the built-in ModelActorDatabase
let database = ModelActorDatabase(modelContainer: container)
```

#### Creating Your Own Database Type

You can also create your own database type by implementing the `Database` protocol:

```swift
@ModelActor
actor CustomDatabase: Database {
}
```

#### Using SharedDatabase

To avoid issues with multiple ModelContexts being created each time SwiftUI redraws views, use `SharedDatabase` to ensure a single shared context:

```swift
public struct SharedDatabase {
    public static let shared: SharedDatabase = .init()

    public let schemas: [any PersistentModel.Type]
    public let modelContainer: ModelContainer
    public let database: any Database

    private init(
        schemas: [any PersistentModel.Type],
        modelContainer: ModelContainer? = nil,
        database: (any Database)? = nil
    ) {
        self.schemas = schemas
        // add cde to handle schema failure
        let modelContainer = try! modelContainer ?? ModelContainer(for: Schema(forTypes))
        self.modelContainer = modelContainer
        self.database = database ?? ModelActorDatabase(modelContainer: modelContainer)
    }
}
```

Then set up the database in your SwiftUI app:

```swift
var body: some Scene {
    WindowGroup {
        RootView()
    }
    .database(SharedDatabase.shared.database)
    /* If you need @Query support
    .modelContainer(SharedDatabase.shared.modelContainer)
    */
}
```

Access the database in your views using the environment:

```swift
@Environment(\.database) private var database
```

### Making Queries

DataThespian provides [a type-safe way to query your data](https://brightdigit.com/tutorials/swiftdata-crud-operations-modelactor/):

```swift
// Fetch a single item
let item = try await database.get(for: .predicate(#Predicate<Item> { 
    $0.name == "Test" 
}))

// Fetch multiple items with sorting
let items = await database.fetch(for: .descriptor(
    predicate: #Predicate<Item> { $0.isActive },
    sortBy: [SortDescriptor(\Item.timestamp, order: .reverse)]
))

// Insert new item
let timestamp = Date()
let newItem = await database.insert { 
    Item(name: "Test", timestamp: timestamp) 
}

// Save changes
try await database.save()

// Re-query after save using a unique field
let savedItem = try await database.getOptional(for: .predicate(#Predicate<Item> { 
    $0.timestamp == timestamp 
}))
```
<!--

## Listening for Changes

Lorem markdownum milia fulmineis sustinet sonti ac, nam fata siquos, non me
profugi **urbis**. Misit aevo quos illi putes: latura tibi illo, a bibes
qualibet? Ora reparata coniunx.

```
hard_subnet -= character;
tunneling_executable_power.unmount = workstation.search(ppp, host_mashup_mysql,
        microcomputer.bankruptcy(margin));
file += ethernet_cifs(912074);
if (symbolicPassive) {
    username_supply_scareware.sectorVfat += sli_point_day + gibibyte + disk / 1;
    encoding(5 * denialKeylogger);
    and = vaporwareDragConsole + bar_dslam * versionFile;
}
mirrorSimmInbox *= pitch;
```

Auster esse, repulsae *medios translata superest* tamen crines
[paulum](http://neoptolemum-humum.com/dimittere-corpora.aspx), mittere
frugiferas. Date inpulit, velocior a tempore Troia. Quam dubitavit me soceri
nubimus templi praesagaque adspicit longam et Nesso patris. Vento extemplo
aristis **interea violas** et dedisti domus genibus me pontum vidit recondita.
**Nubila locum**.

## Synchronizing Data

Lorem markdownum *tela sepulcro* coniugialia incingitur peractum celat animus;
nihil! Ad dabit, mihi indoluit, regno adiere et quidem patefecit victima. Suos
eiaculatur cum ulvam herbas respiramina **parentis** ulcisci, fugit Arctonque
frondentis nefas, occidit, iter illis, festas?

```
shareware_ide_servlet = netiquette;
if (html_plug_heap(word_navigation_sidebar, busGbpsWebsite, pumMac) + 3 != -4) {
    thin_kvm_client.toolbar = trim(4, ieee_load_metal.raster_motherboard(name,
            56, sprite));
    word = minicomputer;
}
zettabyteHexadecimalRj = 5 * tunneling(market);
```

Cum nisi mihi Iuno aetas namque hastamque culpam. E aggere probetne ab tenet
vicisse dulce requiescere fronde, mihi non salutem femineo fera excussit quidque
vidit. Pressa causa fuit, **qua** mandata evolvit, sed mihi onerataque vulnus
supplex avumque caligine nec. Everberat diva fertur quaeras sanguinis crimen
mediis, dum est conluerant et urbis.

Utere spiritus simul in mihi illum vix in cum Aeoliique. Quae tormenta: undis
Volturnus facitote ventos. Stagnumque ignis, nostra habent, viam regna, litore
quibus. Voce terra minis ne classe [habebunt](http://www.datique.org/) vestibus.
Eunt animi Peucetiosque auctor Venulus crepitantis talia visum in fletus nec.

Arte est; pectore prius fecitque Mopsopium Ulixem non succedit palato. Reccidat
*castris corripitur quod* tuo, scelus in erat in. Dedissent Lucinam collo
silentia at vires. Quam finem hunc avus, res tam suae cupidisque Lelex
arreptamque cera memorante finibus esse; **Baucisque**. Fuerunt petentem conata
mox angulus *quibus traxerat* veros, ceu.

```
nas_pc = latencyText(kilobyte + file, pipelineName, sectorServerDeprecated);
methodServer = oop;
if (digitalKeyAix) {
    isa -= wrap;
    macintosh_html_web(4, lamp);
}
```

Pro se nec ire, fremitu, **et fulgure luctibus**. Haut sentit dilapsum stamina
meritis digitos. Quamcumque inque.

Collo [natus](http://astyagesvultusque.com/daedalusgravem.aspx) nequiquam
similem erubuisse spectare: sit iamdudum terga, mittit. Monstri telum cecidisse
haesurum exhortor curvos adhuc, umbras caelo. Infecta iram deus, sed et, nostra,
inplevere tune erant. Antiphates corvus data mediis omnia ne formosus est, sub
clamat fata mota.
-->

## Documentation

To learn more, check out the full [documentation](https://swiftpackageindex.com/brightdigit/DataThespian/documentation).

# License 

This code is distributed under the MIT license. See the [LICENSE](https://github.com/brightdigit/DataThespian/LICENSE) file for more info.
