##A narrative for the video:

00:00 The opening shot is my laptop screen displaying a BT Peripheral app and a QR code that encodes the URL https://blueclip.com. The peripheral app has characteristics for RGB values. The values of the characteristics are displayed as the corresponding color and as text values below the color swatch.

00:07 Another device uses the camera to scan the QR code.  iOS recognizes QR code and the URL as opening an app clip and presents a banner.

00:11 Tapping the banner loads the App Clip Card. Tapping open on the card launches the App Clip.

00:17 The app clip makes a BT connection to the peripheral app (color on the central changes to match the peripheral)

00:20 Using the sliders on the central app changes the values and color on the peripheral app.

Special effects notes:

- The app clip card is set up as a “local experience” for development testing purposes.  Scanning the QR code on a device that is not configured with the local experience will attempt to load https://blueclip.com.  Making the experience available to a broader audience would entail a web server, test flight and a few hours to get it all up and running.