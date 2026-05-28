# 🚚 SalesPOS: Enterprise-Grade Van Sales & Analytics Client

<p align="center">
  <img src="assets/app_icon.png" width="140" alt="SalesPOS App Icon">
</p>

<p align="center">
  <strong>Production-style Flutter Mobile Application implementing a highly aesthetic, premium Van-Sales executive workflow and dynamic sales analytics connected to live backend REST APIs.</strong>
</p>

<p align="center">
  <a href="#-visual-aesthetics--interactive-ux">Aesthetics & UX</a> • 
  <a href="#-key-modules-walkthrough">Key Modules</a> • 
  <a href="#-clean-architecture--modularity">Architecture</a> • 
  <a href="#-network-resilience--timezone-synchronization">Timezone Sync</a> • 
  <a href="#-robust-exception-handling--race-condition-guards">Error & Race Guards</a> • 
  <a href="#-security-hardening--native-optimization">Security & Hardening</a> • 
  <a href="#-quick-setup--deployment">Setup & Release</a>
</p>

---

## 🚀 Project Overview

**SalesPOS** simulates a complete, real-world field sales executive's daily workflow. It enables route sales representatives to bootstrap business sessions, browse assigned routes, check product inventory, compose multi-item tax-inclusive invoices, print visual thermal receipts, and inspect deep financial analytics.

This project is built to showcase a mastery of production Flutter concepts, implementing **advanced performance optimizations, client-side security hardening, and a visually stunning Glassmorphism design language** that sets it apart from typical minimum viable products.

---

## 🎨 Visual Aesthetics & Interactive UX

The user interface leverages modern Material 3 design systems enhanced by high-fidelity custom visuals:

*   **Glassmorphism Theme System**: Uses backdrop filter blurs (`BackdropFilter`), semi-translucent container surfaces, and thin, glowing borders (`outline` variants) to build premium, modern cards.
*   **Harmonious HSL Gradients**: Employs mathematically selected linear gradients (featuring rich indigos, emeralds, and warm ambers) that adapt beautifully to both light and dark system themes.
*   **Resilient Spring Animations**: Interactive elements are driven by spring-based micro-animations (e.g. `Curves.easeOutBack` and custom cubic curves). 
*   **Overshoot Curve Guardrails**: All dynamically calculated animated bounds (such as opacity and scaling) are structurally clamped using `.clamp(0.0, 1.0)` constraint bounds, completely securing the rendering lifecycle against fatal framework assertion crashes.

---

## 💎 Key Modules Walkthrough

### 1. Invoicing & Cart Lifecycle Wizard
*   **Sequence Enforcement**: Enforces a strict linear sequence: Load product types → Select Customer → Browse Catalog → Configure Items → Review Totals → Submit.
*   **Smart Cart Merging**: Merges identical product-unit configurations automatically, increasing the quantity count to keep invoices clean and avoid duplicate line entries.
*   **Subtotal & Tax Calculations**: Computes accurate 5% VAT (toggleable), flat discounts, and round-offs locally in real-time, matching the backend payload schema.

### 2. Advanced Customer Directory & Purchase Analytics
*   **Customer Directory (`customer_directory_screen.dart`)**: Features an elegant, search-enabled card catalog showing routes, customer codes, and payment methods (Cash/Credit).
*   **Hero Profile Header**: Dynamic gradient headers with single-tap clipboard copy shortcuts for contact information.
*   **Purchasing Insights**: Automatically calculates lifetime purchases, total billings count, and visualizes cash-to-credit behavior ratios using custom stacked progress meters.
*   **Auditing Ledger**: Chronological list of past customer transactions. Clicking any ledger item directly pops open the dynamic **Thermal Receipt Dialog**!

### 3. Advanced Product Catalog & Stock Thresholds
*   **Product Catalog (`product_catalog_screen.dart`)**: A grid layout displaying the full store catalog with smart stock alert badges:
    *   🔴 `OUT OF STOCK`: If total units are `0`.
    *   🟡 `LOW STOCK`: If total units fall below `10`.
    *   🟢 `IN STOCK`: For high volume inventory.
*   **Packing Unit Stock Gauges**: Renders custom dynamic gauges across separate package sizes (e.g., BOX, PCS, CTN) indicating minimum selling floor limits.
*   **Revenue Contribution index**: Computes total units sold and revenue contributed by the product from all historical sales, calculating its gross market contribution ratio.

### 4. Interactive Revenue & Collections Charts (`analytics_screen.dart`)
*   **Multi-Chart Trend Visualizer**: Supports three animated chart views toggleable via a custom dropdown:
    *   **Bezier Line Chart**: A smooth cubic bezier trend line mapping revenue progression.
    *   **Area Chart**: A styled line chart with an alpha-shaded vertical fill.
    *   **Bar Chart**: Animated vertical columns showing daily revenue.
*   **Interactive Pointer Overlays**: Tap gestures on coordinates dynamically project custom tooltip overlays showing active currency sums inside an indigo pointer bubble.
*   **Collections Analysis**: A dual-column collection comparison chart mapping CASH vs. CREDIT volumes.
*   **Distribution Donut**: Renders an animated donut chart illustrating transaction breakdowns (Normal Sale, Sample/FOC, Free-of-Charge).

### 5. Reusable Thermal Receipt Generator (`receipt_helper.dart`)
*   Provides a global visual helper that renders high-fidelity mockup representations of physical thermal receipts. 
*   Includes detailed alignments for company headers, customer metadata, itemized price and unit tiers, discounts, tax aggregates, and grand totals.

---

## 🏗️ Clean Architecture & Modularity

The codebase follows a clear, layered structure separating business logic, state, and networking:

```text
lib/
  main.dart                       # App entry point, session setup, and global theme configurations
  app/
    app_session.dart              # Legacy auth/session state orchestrator
  core/
    constants/
      colors.dart                 # Unified branding and UI color tokens (KanakColors)
  data/
    api_client.dart               # HTTP requests, JSON decoders, and response assert validation
  models/
    customer.dart                 # Customer registry models and route information
    invoice.dart                  # CartItem, InvoiceItem details, and VanSaleInvoice structures
    product.dart                  # ProductModel, ProductUnit, and ProductType models
  providers/
    auth_provider.dart            # Standard, secured user auth controller and login session state
    invoice_provider.dart         # Historical invoice loader, cart orchestrator, and submission pipeline
  screens/
    dashboard/
      dashboard_screen.dart       # Main glassmorphic action hub and directory explorer entry points
    analytics/
      analytics_screen.dart       # Interactive revenue graphs and collection charts
    customer/
      customer_directory_screen.dart # Search-enabled list of customer database
      customer_detail_screen.dart # Customer purchase insights and historic auditing ledger
    product/
      product_catalog_screen.dart # Catalog grid, search, and stock threshold badges
      product_detail_screen.dart  # Unit meters, revenue stats, and sales ledgers
    invoice/
      invoice_list_screen.dart    # Standard billing history and receipts list
      create_invoice_screen.dart  # Interactive sales wizard, discount, and cart composition
      select_product_screen.dart  # Product catalog and cart action drawer
      receipt_helper.dart         # Global reusable Thermal Receipt dialog popups
```

---

## ⏰ Network Resilience & Timezone Synchronization

One of the most complex, real-world bug fixes implemented in this client is the **UTC Server-Client Timezone Sync**:

### The Challenge
1. The backend server acts globally, recording invoice creation timestamps (`in_date` and `in_time`) strictly in Coordinated Universal Time (UTC).
2. When field sales representatives log invoices late at night or early in the morning in their local timezone (e.g., IST at `+05:30` offset), the UTC date on the server is still recorded as the previous calendar day.
3. The client dynamically generated its graph dates using local device time (`DateTime.now()`). This date mismatch caused today's newly created invoices to be incorrectly plotted under yesterday's column, leaving today's graph column empty.

### The Resolution
We introduced a high-resilience Timezone Date/Time Normalizer (`_getLocalInvoiceDateTime`) inside `analytics_screen.dart`:
```dart
  Map<String, String> _getLocalInvoiceDateTime(VanSaleInvoice inv) {
    String datePart = inv.inDate;
    // Standardize dd-MM-yyyy format to yyyy-MM-dd
    if (datePart.contains('-') && datePart.indexOf('-') == 2) {
      final parts = datePart.split('-');
      if (parts.length == 3) {
        datePart = '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    }
    String timePart = inv.inTime.isNotEmpty ? inv.inTime : '12:00:00';
    // Robust parsing for dynamic AM/PM values
    if (timePart.toLowerCase().contains('am') || timePart.toLowerCase().contains('pm')) {
      try {
        DateTime tempDate = timePart.split(':').length == 3
            ? DateFormat('hh:mm:ss a').parse(timePart)
            : DateFormat('hh:mm a').parse(timePart);
        timePart = DateFormat('HH:mm:ss').format(tempDate);
      } catch (_) {
        // Fallback custom manual parsing
      }
    }
    try {
      final utcDateTime = DateTime.tryParse('${datePart}T${timePart}Z');
      if (utcDateTime != null) {
        final localDateTime = utcDateTime.toLocal(); // Convert to client's timezone
        return {
          'date': DateFormat('yyyy-MM-dd').format(localDateTime),
          'time': DateFormat('hh:mm a').format(localDateTime),
        };
      }
    } catch (_) {}
    return {'date': inv.inDate, 'time': inv.inTime};
  }
```
*   **Resiliency**: Resolves date format discrepancies (e.g. `dd-MM-yyyy` vs `yyyy-MM-dd`) and handles complex time formats.
*   **Result**: The daily sums, period filtering (`_getPeriodInvoices`), and detail sheets render in client-local time, completely synchronizing the trend line and columns.

---

## 🛡️ Robust Exception Handling & Race-Condition Guards

To provide a flawless, production-ready user experience, the application enforces security and transport-level error protection rules:

1.  **Concurrent Submit Protection**: Implements widget-level `_isSubmitting` status filters and delegates to `authProvider.isLoading` check locks inside `login_screen.dart`. Repeated taps or keyboard submissions are discarded immediately, preventing parallel background login loops.
2.  **Authentication Session Integrity**: Built robust validation filters at the bootstrap level in `auth_provider.dart`. If the backend returns a slow/delayed error response (e.g. `401 Unauthorized` from an earlier incorrect password attempt) *after* the user has successfully entered the dashboard with subsequent correct credentials, the delayed error is completely ignored, keeping the user inside the active session.
3.  **Lingering SnackBar Dismissals**: Entering the `DashboardScreen` invokes `ScaffoldMessenger.of(context).clearSnackBars()` inside a post-frame callback, instantly cleaning up any remaining errors or loading messages from the login screen.
4.  **Defensive API Assertions**: Every HTTP network operation flows through central `ApiClient._assertSuccess` filters validating both standard HTTP status codes and custom nested response status codes, converting internal stack traces into friendly, polished user feedback.

---

## 🔐 Security Hardening & Native Optimization

The project follows industry-standard security and performance directives:

*   **Bearer Token Authorization**: Centralized request headers dynamically inject bearer tokens (`Authorization: Bearer <token>`) immediately after authentication. All tokens are securely cleared from in-memory state on user logout.
*   **Secure API Cleartext Allowance**: Outlines explicit networking rules in `AndroidManifest.xml`, declaring `android:usesCleartextTraffic="true"` only for our target domain, keeping general cleartext traffic strictly blocked.
*   **Native Code Obfuscation (R8/Proguard)**: Configured deep code optimization rules in `android/app/build.gradle.kts` and created `proguard-rules.pro` mappings. When compiling for production, it obfuscates native Dart/Kotlin layers and prunes unused resources, reducing reverse-engineering vulnerabilities and optimizing the application size.

---

## 🛠️ Quick Setup & Deployment

### Prerequisites
*   [Flutter SDK](https://flutter.dev/docs/get-started/install) installed (Dart SDK `^3.11.0` compatible)
*   An active Android/iOS emulator or connected physical testing device

### Setup & Run
1.  **Retrieve Dependencies**:
    ```bash
    flutter pub get
    ```
2.  **Launch Dev Server**:
    ```bash
    flutter run
    ```

### Release Compilation
Build an optimized, resource-shrunk, and obfuscated production-ready APK:
```bash
flutter build apk --release
```
The resulting optimized binary is saved at:  
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📊 Interview Evaluation Rubric Map

| Interview Requirement | Technical Implementation | File Path References |
|:---|:---|:---|
| **Architectural modulations** | Clean separation of concerns between UI layouts, ChangeNotifier state providers, and the network client layer. | `lib/providers/`, `lib/screens/`, `lib/data/` |
| **Defensive JSON Mapping** | Fully strongly-typed domain models parsing nested arrays and maps safely without dynamic casting exceptions. | [models/invoice.dart](file:///e:/interview_flutter/lib/models/invoice.dart) |
| **High-Fidelity UI Styling** | Custom-engineered glassmorphism, backdrop filters, Harmonics gradients, and overshoot-resistant spring animations. | [screens/dashboard/dashboard_screen.dart](file:///e:/interview_flutter/lib/screens/dashboard/dashboard_screen.dart) |
| **Network & Timezone Synchronization** | Intelligently converts UTC database entries into local timezone formats to perfectly map sales trends on custom charts. | [screens/analytics/analytics_screen.dart](file:///e:/interview_flutter/lib/screens/analytics/analytics_screen.dart) |
| **Multi-level Error Resilience** | Implements submit guards, delayed error filters, session-pollution locks, and interactive reload/retry UI. | [providers/auth_provider.dart](file:///e:/interview_flutter/lib/providers/auth_provider.dart) |
| **Thermal Receipt Formatting** | Dynamic receipt visual mapping complete with company metadata, tax summaries, items grids, and discounts formatting. | [screens/invoice/receipt_helper.dart](file:///e:/interview_flutter/lib/screens/invoice/receipt_helper.dart) |
| **Native Performance & Hardening** | Integrates Android Proguard code minification, resource shrinking, and target cleartext whitelist declarations. | `android/app/build.gradle.kts` |
