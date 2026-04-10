# quickmartcustomer

A new Flutter project.


Auto geolocation + places (customer address + vendor profile)
I can implement this next, but you need API/project setup first:

Create/select a Google Cloud project.
Enable APIs:
Places API
Geocoding API
(optional) Maps JavaScript API for richer web autocomplete
Create API key and restrict it.
Add key in platform configs:
Android: android/app/src/main/AndroidManifest.xml
iOS: ios/Runner/AppDelegate / plist
Web: web/index.html (if JS Places widget used)
Choose integration style:
Native geolocation only (lat/lng + reverse geocode)
Places autocomplete + pick precise address
Persist in backend:
Customer address: geolocation should store lat,lng or place_id+lat,lng
Vendor profile: same pattern
If you want, next I’ll implement the full UI + payload updates for both customer and vendor with a safe fallback when location permission is denied.