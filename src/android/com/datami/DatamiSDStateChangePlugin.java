package com.datami;

import com.datami.smi.SdState;
import com.datami.smi.SmiSdk;
import com.datami.smi.SdStateChangeListener;
import com.datami.smi.SmiResult;
import com.datami.smi.Analytics;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import android.annotation.SuppressLint;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by damandeepsingh on 09/10/17.
 */

public class DatamiSDStateChangePlugin extends CordovaPlugin {
    private static CallbackContext connectionCallbackContext;


    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
    }

    @SuppressLint("LongLogTag")
    public static void onChange() {
        String sdState = "";
        sdState = DatamiApplication.smiResult.getSdState().name();
        if (DatamiApplication.smiResult.getSdState() == SdState.SD_NOT_AVAILABLE) {
            sdState = sdState + ", Reason: "+DatamiApplication.smiResult.getSdReason().name();
        }
        if (connectionCallbackContext != null) {
            Log.d("DatamiSDStateChangePlugin","Sending Result");
            PluginResult result = new PluginResult(PluginResult.Status.OK, sdState);
            result.setKeepCallback(true);
            connectionCallbackContext.sendPluginResult(result);
        }
    }

    @SuppressLint("LongLogTag")
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        Log.d("DatamiCordova","Action: "+action);
        for(int i = 0; i < args.length(); i++) {
            Log.d("DatamiCordova","Arg" +i+": "+args.get(i).toString());
        }
        if (action.equals("getSDState")) {
            Log.d("DatamiSDStateChangePlugin","getSDState");
            this.connectionCallbackContext = callbackContext;

            String sdState = "";

            if (DatamiApplication.smiResult != null) {
                sdState = DatamiApplication.smiResult.getSdState().name();
                if (DatamiApplication.smiResult.getSdState() == SdState.SD_NOT_AVAILABLE) {
                    sdState = sdState + ", Reason: "+DatamiApplication.smiResult.getSdReason().name();
                }
            }

            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, sdState);
            pluginResult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginResult);
            return true;
        }
        else if (action.equals("getAnalytics")) {
            Analytics abc = SmiSdk.getAnalytics();
            JSONObject dataObject = new JSONObject();

            try {
                dataObject.put("CellularSessionTime",abc.getCellularSessionTime());
                dataObject.put("SdDataUsage",abc.getSdDataUsage());
                dataObject.put("WifiSessionTime",abc.getWifiSessionTime());
                PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, dataObject);
                pluginResult.setKeepCallback(false);
                callbackContext.sendPluginResult(pluginResult);
                return true;
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        else if (action.equals("updateUserId")) {
            String userid = args.getString(0);
            if (userid != null && userid.length() > 0) {
                SmiSdk.updateUserId(userid);
                PluginResult pluginResult = new PluginResult(PluginResult.Status.OK);
                pluginResult.setKeepCallback(false);
                callbackContext.sendPluginResult(pluginResult);
            } else {
                PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR);
                pluginResult.setKeepCallback(false);
                callbackContext.sendPluginResult(pluginResult);
            }
            return true;
        }
        else if (action.equals("updateUserTag")) {
            List<String> tags = new ArrayList<String>();
            JSONArray array = args.getJSONArray(0);
            for(int i=0; i<array.length(); i++) {
                tags.add(array.getString(i));
            }
            if (tags.size() > 0) {
                SmiSdk.updateUserTag(tags);
                PluginResult pluginResult = new PluginResult(PluginResult.Status.OK);
                pluginResult.setKeepCallback(false);
                callbackContext.sendPluginResult(pluginResult);
            } else {
                PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR);
                pluginResult.setKeepCallback(false);
                callbackContext.sendPluginResult(pluginResult);
            }
            return true;
        }
        else if (action.equals("getSDAuth")) {
            String url = args.getString(0);
            JSONObject dataObject = new JSONObject();
            try {
                SmiResult result = SmiSdk.getSDAuth(DatamiApplication.API_KEY,cordova.getActivity().getApplicationContext(),url);
                dataObject.put("SdState",result.getSdState().name());
                dataObject.put("Url",result.getUrl());
                dataObject.put("CarrierName",result.getCarrierName());
                dataObject.put("ClientIp",result.getClientIp());
                PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, dataObject);
                pluginResult.setKeepCallback(false);
                callbackContext.sendPluginResult(pluginResult);
            } catch (Exception e) {
                PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR);
                pluginResult.setKeepCallback(false);
                callbackContext.sendPluginResult(pluginResult);
                e.printStackTrace();
            }
            return true;
        }
        else if (action.equals("startSponsoredData")) {
                try{
                SmiSdk.startSponsoredData();
            }
            catch(Exception e) {
                e.printStackTrace();
            }
                PluginResult pluginResult = new PluginResult(PluginResult.Status.OK);
                pluginResult.setKeepCallback(false);
                callbackContext.sendPluginResult(pluginResult);
            return true;
        }
        else if (action.equals("stopSponsoredData")) {
                SmiSdk.stopSponsoredData();
                PluginResult pluginResult = new PluginResult(PluginResult.Status.OK);
                pluginResult.setKeepCallback(false);
                callbackContext.sendPluginResult(pluginResult);
            return true;
        }
        return false;
    }

}
