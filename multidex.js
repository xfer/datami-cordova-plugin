module.exports = function(ctx) {
    var fs = ctx.requireCordovaModule('fs'),
        path = ctx.requireCordovaModule('path'),
        xml = ctx.requireCordovaModule('cordova-common').xmlHelpers;

    var manifestPath = path.join(ctx.opts.projectRoot, 'platforms/android/AndroidManifest.xml');
    var doc = xml.parseElementtreeSync(manifestPath);
    if (doc.getroot().tag !== 'manifest') {
        throw new Error(manifestPath + ' has incorrect root node name (expected "manifest")');
    }

    //adds the tools namespace to the root node
    // doc.getroot().attrib['xmlns:tools'] = 'http://schemas.android.com/tools';
    //add tools:replace in the application node
    if(doc.getroot().find('./application').attrib['android:name'] == 'android.support.multidex.MultiDexApplication') {
        doc.getroot().find('./application').attrib['android:name'] = 'com.datami.DatamiApplication';
        fs.writeFileSync(manifestPath, doc.write({indent: 4}), 'utf-8');


        var appPath = path.join(ctx.opts.projectRoot, 'platforms/android/src/com/datami/DatamiApplication.java');
        fs.readFile(appPath, 'utf8', function (err,data) {
  if (err) {
    return console.log(err);
  }
  var result = data.replace(/extends Application/g, 'extends android.support.multidex.MultiDexApplication');

  fs.writeFile(appPath, result, 'utf8', function (err) {
     if (err) return console.log(err);
  });
});

    }
    else {
    	doc.getroot().find('./application').attrib['android:name'] = 'com.datami.DatamiApplication';
        fs.writeFileSync(manifestPath, doc.write({indent: 4}), 'utf-8');
    }
    //write the manifest file
    
};
