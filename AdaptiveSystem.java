package com.leber.quadrad;

import android.app.Activity;
import android.content.Context;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.google.android.gms.maps.model.LatLng;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.NumberFormat;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Locale;
import java.util.Timer;
import java.util.TimerTask;


public class AdaptiveSystem {

    //Benötige Objekte aus anderen Klassen
    private Activity activity;
    private Context context;
    private LinearLayout slider;
    private LinearLayout slider_layout;
    private RangeIndicatorView rangeIndicatorView;

    //CONSTANTS:


    /* Timerkonstanten, wie oft und mit welcher Verzögerung ab Start die Hauptfunktion und die Herzfrequenzregelung ausgeführt werden sollen in ms: */


    //TODO: DMEYER
    private final int TIMER_HEARTRATE_CONTROL = 10000; //ms
    private final int DELAY_HEARTRATE_CONTROL = 2000; //ms
    private final int TIMER_RANGE = 10000; //ms
    private final int DELAY_RANGE = 2000; //ms




    /* Hier kommen sämtliche Konstanten hin. Bitte sprechende Variablen verwenden    */

    //Gender
    private final int MALE = 0;
    private final int FEMALE = 1;

    //Bike Tyres
    private final int MOUNTAINBIKE = 0;
    private final int TREKKINGBIKE = 1;
    private final int RACINGBIKE  = 2;

    //Surface
    private final int ASPHALT = 0;
    private final int GRAVEL = 1;
    private final int MUD = 2;

    // ############################################################################################
    // ############################################################################################
    // author:  Meyer 30.06.2015
    //          Meyer 03.07.2015
    // Diese Variablen und Konstanten wurden von mir angelegt
    private final int REFERENCE_CADENCE = 70; // [rpm]
    private final int LOW_INTENSITY = 75;     // [W]

    // Konstanten für Controller
    private final int ETA = 1;                // [-]
    private final double EPSILON = 0.1;        // [-]
    private final int LOWER_LIMIT = -50;      // [Nm]
    private final int UPPER_LIMIT = 50;       // [Nm]

    // Konstanten QuadRad
    private final double REARWHEELRADIUS = 0.33; // [m];
    private final double GEAR = 2.46;
    private final int DESIREDVELOCITY = 6;        // [m/s]

    // Parameter für Herzfrequenzmodell
    private final double PARAMETER_a1 = 0.0113;
    private final double PARAMETER_a2 = 0.0072;
    private final double PARAMETER_a3 = 0.0049;
    private final double PARAMETER_a4 = 0.0041;
    private final double PARAMETER_a5 = 19.8002;
    private final double PARAMETER_a6 = 0.0072;
    private final int RESTING_HEARTRATE = 75;


    // Variablen für Herzfrequenzregelung
    private double lastDerivativeGradualHeartRateResponse = 0;
    private double lastGradualHeartRateResponse = 0;
    private double hr_max = 0;
    private double hr_IAT = 0;
    private double hr_1 = 0;
    private double p_max = 0;
    private double p_IAT = 0;
    // ############################################################################################
    // ############################################################################################








    //Motordaten:

    private int motorDataCounter; //Anzahl der Datensätze

    private float[] torqueValues; //Drehmoment
    private float[] frequencyValues; //Drehzahl
    private float[] voltageValues; //Spanung
    private float[] currentValues; //Strom
    private float[] efficiencyValues; //Wirkungsgrad


    //Batteriedaten: //TODO
    private float[] voltageChargeValues; //Entladekurve Batterie



    //DRIVER: (values will be read from driver.csv)

    private int driverNumber;
    private int gender;
    private int age;
    private int height;
    private int weight;
    private int fitness;


    //E-BIKE: (values will be read from bikes.csv)

    private int bikeNumber; //Numerierung
    private int bikeWeight; //Fahrzeugmasse
    private float cwValue; //CW-Wert * A
    private int tyres; //Fahrzeugbereifung
    private int motor; //Verbauter Motor
    private int battery; //Verbaute Batterie


    //ROUTE: (values will be read from routeN.csv)
    //Hier werden Arrays verwendet, in die die Parameter für die Abschnitte [0...N] gespeichert werden können

    public static ArrayList<ArrayList<LatLng>> route; //Ein Array aus Arrays mit Wegpunkten. Jedes innere Array repräsentiert einen Streckenabschnitt, des äußere Array ist die Gesamtstrecke.

    private int subRouteCounter; //Anzahl der Streckenabschnitte

    private int subRouteNumber[]; //Numerierung
    private float  subRouteLength[];      //Streckenabschnittslänge
    private int subRouteSurface[]; //Untergrund
    private float subRouteHeight[];        //Höhendifferenz
    private float subRouteSpeed[]; // Durchschnitts(?)-Geschwindigkeit


    //HF-Parameter: (values will be written from MainProcess)

    private int distance[]; //Einzellänge

    private int maxHeartRate[];
    private int targetHeartRate;
    private int maxMotorPower[];
    private int maxCadence[];


    //Statusindikatoren
    private float startKilometer;


    //CONSTRUCTOR:

    public AdaptiveSystem() {
        super();
        slider = FragmentMain.getSlider(5);
        slider_layout = (LinearLayout) slider.findViewById(R.id.slider_sixth);
    }

    public AdaptiveSystem(Context context) {
        this();
        this.context = context;
    }

    public AdaptiveSystem(Context context, Activity activity) {
        this(context);
        this.activity = activity;
    }


    //METHODS:
    /* Methoden, die die Klasse bereitstellen soll */


    // Hauptfunktion, die zB timergesteuert alle x Millisekunden aufgerufen wird. In dieser Funktion wird anhand eines Vergleichs von Soll- und Istwerten entschieden, ob etwas geschehen soll.

    private void mainProcess() {
        //TODO:Calculate real values for soc after subRoute
        //
        // TODO: DMEYER;


        int[] socAfterRoute = {100, 74, 49}; //Will be replaced after implementation



        //Graphische Darstellung der Restladung. Bitte nicht ändern.
        slider_layout.removeAllViews();
        rangeIndicatorView = new RangeIndicatorView(context);
        rangeIndicatorView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 150));
        slider_layout.addView(rangeIndicatorView);

        rangeIndicatorView.setRoute(this.subRouteCounter, socAfterRoute, subRouteLength, startKilometer);
        rangeIndicatorView.invalidate();
    }


    // #############################################################################################
    // #############################################################################################
    // author:  Meyer 30.06.2015
    //          Meyer 03.07.2015
    // Diese Methode habe ich angelegt, um die physiologischen Parameter zu berechnen
    // @ Markus: Die Methode muss im Code aufgerufen werden, nachdem die individuellen Daten eingelesen wurden

    public void readPhysiologicalParameters() {
        // Berechnung von individuellen Parametern
        // Berechnung der maximalen Herzfrequenz und Leistung des Fahrers und der HF und Leistung an der individuellen anaeroben Schwelle
        int BMICount = -1;
        int ageCount = -1;
        double height_BMI = (double)height;
        double BMI = weight/(height_BMI*height_BMI/10000);
        if (BMI<25) {
            BMICount = 0;
        }
        else {
            BMICount = 1;
        }

        if (age<35) {
            ageCount = 0;
        }
        else if (age<65) {
            ageCount = 1;
        }
        else {
            ageCount = 2;
        }

        // Berechnung der maximalen Herzfrequenz des Fahrers
        // ##################################
        // ### HR_max = b0_HR + b1_HR*age ###
        // ##################################
        // Definition der Koeffizienten: Unterteilung in BMI<25 (Werte 0-2) und BMI>25 (Werte 3-5) und Fitness (jeweils + 1/2/3)
        double[] b0_HR = {208, 206, 210, 211, 204, 213};
        double[] b1_HR = {-0.83, -0.68, -0.72, -1.05, -0.76, -0.85};
        hr_max = b0_HR[BMICount*3+fitness-1]+b1_HR[BMICount*3+fitness-1]*age;

        // Berechnung der maximalen Leistung des Fahrers
        // #############################################
        // ### P_max = b0_P + b1_P*age + b2_P*weight ###
        // #############################################
        // Definition der Koeffizienten: Unterteilung in männlich (Werte 0-2) und weiblich (Werte 3-5) und Fitness (jeweils + 1/2/3)
        double[] b0_P = {160.86, 323.98, 252.15, 186.15, 170.84, 170.84};
        double[] b1_P = {-1.23, -1.47, -0.96, -1.19, -0.82, -0.82};
        double[] b2_P = {0.93, -0.13, 0.96, 0.21, 0.66, 0.66};
        p_max = b0_P[gender*3+fitness-1] + b1_P[gender*3+fitness-1]*age + b2_P[gender*3+fitness-1]*weight;

        // Berechnung von Herzfrequenz (HR_IAT) und Leistung (P_IAT) an der individuellen anaeroben Schwelle (IAT) und der Herzfrequenz bei geringer Belastung (HR_1)
        // ################################
        // ### HR_1 = alpha1 * HR_max   ###
        // ### HR_IAT = alpha2 * HR_max ###
        // ### P_IAT = alpha3 * P_max   ###
        // ################################
        // Definition der Koeffizienten:
        // HR_1/HR_IAT: Unterteilung in männlich/weiblich, Alter (<35==Werte 0-2; <65==Werte 3-5; >65==Werte 6-8) und Fitness (jeweils + 1/2/3)
        double[] alpha1Male = {0.61, 0.53, 0.40, 0.61, 0.53, 0.40, 0.66, 0.57, 0.42};
        double[] alpha1Female = {0.65, 0.60, 0.40, 0.65, 0.60, 0.40, 0.72, 0.64, 0.64};
        double[] alpha2Male = {0.84, 0.82, 0.72, 0.84, 0.82, 0.72, 0.88, 0.83, 0.85};
        double[] alpha2Female = {0.85, 0.85, 0.73, 0.85, 0.85, 0.73, 0.86, 0.84, 0.84};

        // Definition der Koeffizienten:
        // P_IAT: Unterteilung in Alter (<35==Werte 0-2; <65==Werte 3-5; >65==Werte 6-8) und Fitness (jeweils + 1/2/3)
        double[] alpha3 = {0.68, 0.68, 0.69, 0.72, 0.70, 0.73, 0.78, 0.72, 0.74};

        double[] alpha1 = {0,0,0,0,0,0,0,0,0};
        double[] alpha2 = {0,0,0,0,0,0,0,0,0};

        if (gender==0) {
            alpha1 = alpha1Male;
            alpha2 = alpha2Male;
        }
        else if (gender==1) {
            alpha1 = alpha1Female;
            alpha2 = alpha2Female;
        }

        hr_1 = alpha1[ageCount*3+fitness-1]*hr_max;
        hr_IAT = alpha2[ageCount*3+fitness-1]*hr_max;
        p_IAT = alpha3[ageCount*3+fitness-1]*p_max;
    }
    // #############################################################################################
    // #############################################################################################


    // #############################################################################################
    // #############################################################################################
    // author:  Meyer 30.06.2015
    //          Meyer 03.07.2015
    // Hier habe ich die Herzfrequenzregelung eingefügt
    //Hier passiert die Herzfrequenzregelgung
    public void heartRateControl() {
        // Herzfrequenzregelung
        // ###################################################################
        // Begriffserklärung:
        // x1 == Herzfrequenz (gemessen)
        // x2 == gradueller (langsamer) Anteil an der Herzfrequenz
        // ...' == Ableitung der entsprechenden Variable
        // ...(t-1) == Wert der Variable beim vorhergehenden Zeitpunkt
        // ###################################################################


        // Teil 1: Feedforward Part
        // Berechnung der Referenzleistung (referencePower) an der vorgegebenen Herzfrequenz (targetHeartRate)
        double referencePower = -1.0;
        if (targetHeartRate<hr_IAT) {
            double gradient = (hr_IAT-hr_1)/(p_IAT-LOW_INTENSITY);
            double offset = hr_IAT-gradient*p_IAT;
            referencePower = ((targetHeartRate-offset)/gradient);
        }
        else if (targetHeartRate>hr_IAT) {
            double gradient = (hr_max-hr_IAT)/(p_max-p_IAT);
            double offset = (int)(hr_max-gradient*p_max);
            referencePower = ((targetHeartRate-offset)/gradient);
        }

        // Berechnung des feedforward Signals
        int referenceTorque = (int)Math.round(referencePower*60/(REFERENCE_CADENCE*2*Math.PI));
        int feedforwardSignal = Data.torque-referenceTorque;

        // Teil 2: Feedback Part
        // Berechnung des Anteils der graduellen Herzfrequenzanpassung
        // #######################################################################################
        // ### x2 = x2'(t-1) + x1*Parameter_a4/(exp(Parameter_a5-x1)+1) + x2(t-1)*Parameter_a3 ###
        // #######################################################################################
        double gradualHeartRateResponse = lastDerivativeGradualHeartRateResponse + ((Data.heart_rate*PARAMETER_a4)/(Math.exp(PARAMETER_a5-Data.heart_rate)+1)+ lastGradualHeartRateResponse*PARAMETER_a3);
        // Berechnung der Differenz aus gewünschter und gemessener Herzfrequenz und Normalisierung
        double normalizedHeartRateError = (targetHeartRate-Data.heart_rate-RESTING_HEARTRATE)/hr_max;
        // Berechnung des Feedback Signals für konstante targetHeartRate
        int feedbackSignal = (int)Math.round(((normalizedHeartRateError/(Math.abs(normalizedHeartRateError)+EPSILON)*ETA + Data.heart_rate*PARAMETER_a1 - gradualHeartRateResponse*PARAMETER_a2)*(-REARWHEELRADIUS*p_max*GEAR/PARAMETER_a6/DESIREDVELOCITY)));

        if (feedbackSignal<LOWER_LIMIT) {
            feedbackSignal=LOWER_LIMIT;
        }
        else if (feedbackSignal>UPPER_LIMIT) {
            feedbackSignal=UPPER_LIMIT;
        }

        // Berechnung des gesamten Kontrollsignals
        int controlSignal = feedbackSignal+feedforwardSignal;
        // Schreiben der Daten
        setHRControlTorque(controlSignal);

        // Berechnete Variablen für nächsten Durchlauf speichern
        lastGradualHeartRateResponse = gradualHeartRateResponse;
        lastDerivativeGradualHeartRateResponse = (gradualHeartRateResponse-lastGradualHeartRateResponse)/TIMER_HEARTRATE_CONTROL/1000;
    }
    // #############################################################################################
    // #############################################################################################


    public void initProcess() {
        startKilometer = Data.distance_total;


        slider_layout.removeAllViews();
        rangeIndicatorView = new RangeIndicatorView(context);

        rangeIndicatorView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 150));
        slider_layout.addView(rangeIndicatorView);


        // Timer für die Methode "mainProcess" --> Dort kommt das Reichweitenmodell rein

        final Runnable mainProcessRunnable = new Runnable() {
            @Override
            public void run() {
                mainProcess();
            }
        };

        TimerTask task = new TimerTask() {
            @Override
            public void run() {
                activity.runOnUiThread(mainProcessRunnable);
            }
        };

        Timer timer = new Timer();
        timer.schedule(task, this.DELAY_RANGE, this.TIMER_RANGE);


        // Timer für die Methode "heartRateControl"
        final Runnable heartRateControlRunnable = new Runnable() {
            @Override
            public void run() {
                heartRateControl();
            }
        };

        TimerTask task_heartrate =  new TimerTask() {
            @Override
            public void run() {
                activity.runOnUiThread(heartRateControlRunnable);
            }
        };

        Timer timer_heartrate = new Timer();
        timer_heartrate.schedule(task_heartrate, this.DELAY_HEARTRATE_CONTROL, this.TIMER_HEARTRATE_CONTROL);


    }





    //Methode zum Einlesen der Routendaten;
    public void readRouteData(int routeNumber) {
        subRouteCounter = 0;
        ArrayList<String[]> routeData = new ArrayList<String[]>();

        this.route = new ArrayList<ArrayList<LatLng>>();
        //TODO: Routenpolygon einlesen MBiberger


        //Create filename String
        StringBuilder sb = new StringBuilder("route");
        sb.append(Integer.toString(routeNumber));
        sb.append(".csv");
        String filename = sb.toString();

        //Open file
        InputStream is = null;
        try {
            is = context.getAssets().open(filename);
        } catch (IOException e) {
            e.printStackTrace();
        }
        BufferedReader reader = new BufferedReader(new InputStreamReader(is));

        try {
            String line;
            //Skip first line
            line = reader.readLine();

            //Now try to read route data;
            while ((line = reader.readLine()) != null) {
                //Keep count of route parts
                subRouteCounter++;
                //Split values at semicolon
                String[] rowData = line.split(";");
                //now read values;
                routeData.add(rowData);
            }
        } catch (IOException ex) {
            // handle exception
        } finally {
            try {
                is.close();
            } catch (IOException e) {
                // handle exception
            }
        }

        this.subRouteNumber = new int[subRouteCounter];
        this.subRouteLength = new float[subRouteCounter];
        this.subRouteSurface = new int[subRouteCounter];
        this.subRouteHeight = new float[subRouteCounter];
        this.subRouteSpeed = new float[subRouteCounter];

        NumberFormat format = NumberFormat.getInstance(Locale.GERMANY);

        for (int i = 0; i < subRouteCounter; i++) {
            this.subRouteNumber[i] = Integer.parseInt(routeData.get(i)[0]);
            this.subRouteSurface[i] = Integer.parseInt(routeData.get(i)[2]);


            try {
                this.subRouteLength[i] = format.parse(routeData.get(i)[1]).floatValue();
            } catch (ParseException e) {
                e.printStackTrace();
            }

            try {
                this.subRouteHeight[i] = format.parse(routeData.get(i)[3]).floatValue();
            } catch (ParseException e) {
                e.printStackTrace();
            }
            try {
                this.subRouteSpeed[i] = format.parse(routeData.get(i)[4]).floatValue();
            } catch (ParseException e) {
                e.printStackTrace();
            }
        }
    }


    //Methode zum Einlesen der Fahrerdaten
    public void readDriverData(int driver) {
        InputStream is = null;
        try {
            is = context.getAssets().open("driver.csv");
        } catch (IOException e) {
            e.printStackTrace();
        }

        BufferedReader reader = new BufferedReader(new InputStreamReader(is));
        try {
            String line;

            //Skip Document header and DRIVER amount of lines to get to the desired driver
            for (int i = 0; i < driver; i++) {
                line = reader.readLine();
                if (line == null) {
                    // handle it
                }
            }
            //Read next line
            line = reader.readLine();
            //Split values at semicolon
            String[] rowdata = line.split(";");
            //Now we have our desired driver parameters saved in the String. Now parse it.

            this.driverNumber = Integer.parseInt(rowdata[0]);
            this.gender = Integer.parseInt(rowdata[1]);
            this.age = Integer.parseInt(rowdata[2]);
            this.height = Integer.parseInt(rowdata[3]);
            this.weight = Integer.parseInt(rowdata[4]);
            this.fitness = Integer.parseInt(rowdata[5]);

        } catch (IOException e) {
            //handle exception
        } finally {
            try {
                is.close();
            } catch (IOException e) {
                //handle exception
            }
        }
    }

    //Methode zum Einlesen der Fahrraddaten
    public void readBikeData(int bike) throws ParseException {
        InputStream is = null;
        try {
            is = context.getAssets().open("bikes.csv");
        } catch (IOException e) {
            e.printStackTrace();
        }

        BufferedReader reader = new BufferedReader(new InputStreamReader(is));
        try {
            String line;

            //Skip Document header and BIKE amount of lines to get to the desired bike
            for (int i = 0; i < bike; i++) {
                line = reader.readLine();
                if (line == null) {
                    // handle it
                }
            }
            //Read next line
            line = reader.readLine();
            //Split values at semicolon
            String[] rowdata = line.split(";");
            //Now we have our desired bike parameters saved in the String. Now parse it.

            NumberFormat format = NumberFormat.getInstance(Locale.GERMANY);

            this.bikeNumber = Integer.parseInt(rowdata[0]);
            this.bikeWeight = Integer.parseInt(rowdata[1]);
            this.tyres = Integer.parseInt(rowdata[3]);
            this.motor = Integer.parseInt(rowdata[4]);
            this.battery = Integer.parseInt(rowdata[5]);

            try {
                this.cwValue = format.parse(rowdata[2]).floatValue();
            } catch (ParseException e) {
                e.printStackTrace();
            }


        } catch (IOException e) {
            //handle exception
        } finally {
            try {
                is.close();
            } catch (IOException e) {
                //handle exception
            }
        }

        //Now directly read motor
        readMotorData(this.motor);
    }


    //Methode zum Einlesen der Motordaten
    public void readMotorData(int motor) throws ParseException {
        motorDataCounter = 0;
        ArrayList<String[]> motorData = new ArrayList<String[]>();

        InputStream is = null;
        try {

            StringBuilder sb = new StringBuilder("motor");
            sb.append(Integer.toString(motor));
            sb.append(".csv");
            String filename = sb.toString();
            is = context.getAssets().open(filename);
        } catch (IOException e) {
            e.printStackTrace();
        }

        BufferedReader reader = new BufferedReader(new InputStreamReader(is));
        try {
            String line;

            //Skip Document header and MOTOR amount of lines to get to the desired motor

            line = reader.readLine(); //Skip first line


            while ((line = reader.readLine()) != null) {
                //Keep count of motor data
                motorDataCounter++;
                //Split values at semicolon
                String[] rowData = line.split(";");
                //now read values;
                motorData.add(rowData);
            }
        } catch (IOException e) {
            //handle exception
        } finally {
            try {
                is.close();
            } catch (IOException e) {
                //handle exception
            }
        }

        this.torqueValues = new float[motorDataCounter];
        this.frequencyValues = new float[motorDataCounter];
        this.voltageValues = new float[motorDataCounter];
        this.currentValues = new float[motorDataCounter];
        this.efficiencyValues = new float[motorDataCounter];

        NumberFormat format = NumberFormat.getInstance(Locale.GERMANY);

        for (int i = 0; i < subRouteCounter; i++) {
            this.torqueValues[i] = format.parse(motorData.get(i)[0]).floatValue();
            this.frequencyValues[i] = format.parse(motorData.get(i)[1]).floatValue();
            this.voltageValues[i] = format.parse(motorData.get(i)[2]).floatValue();
            this.currentValues[i] = format.parse(motorData.get(i)[3]).floatValue();
            this.efficiencyValues[i] = format.parse(motorData.get(i)[4]).floatValue();
        }
    }


    //Methode zum Einlesen der Batteriedaten
    public void readBatteryData(int battery) {
        InputStream is = null;
        try {
            is = context.getAssets().open("battery.csv");
        } catch (IOException e) {
            e.printStackTrace();
        }

        BufferedReader reader = new BufferedReader(new InputStreamReader(is));
        try {
            String line;

            //Skip Document header and BIKE amount of lines to get to the desired bike
            for (int i = 0; i < battery; i++) {
                line = reader.readLine();
                if (line == null) {
                    // handle it
                }
            }
            //Read next line
            line = reader.readLine();
            //Split values at semicolon
            String[] rowdata = line.split(";");
            //Now we have our desired bike parameters saved in the String. Now parse it.


            //TODO: READ DATA. MBiberger


        } catch (IOException e) {
            //handle exception
        } finally {
            try {
                is.close();
            } catch (IOException e) {
                //handle exception
            }
        }
    }



    //Methoden zum Senden von Daten




    public void setHRControlTorque(int torque) { //torque can be 0-70
        if (torque < 0)
        {
            Data.hrcontrolTorque = 0;
        } else if (torque >70) {
            Data.hrcontrolTorque = 70;
        } else {
            Data.hrcontrolTorque = torque;
        }


        MainActivity.bt_process.write(Data.buildMessage(Data.HMI_CONTROL_MSG, Data.HRCONTROL_TORQUE_MSG));
    }

    public void setHRControlAssistLevel(int assistLevel) { //assistLevel can be 0-200

        if (assistLevel < 0) {
            Data.hrcontrolAssistLevel = 0;
        } else if (assistLevel < 200) {
            Data.hrcontrolAssistLevel = 200;
        } else {
            Data.hrcontrolAssistLevel = assistLevel;
        }


        Data.hrcontrolAssistLevel = assistLevel;
        MainActivity.bt_process.write(Data.buildMessage(Data.HMI_CONTROL_MSG, Data.HRCONTROL_ASSIST_LEVEL_MSG));
    }

    public void setHRControlModeOFF() {
        MainActivity.bt_process.write(Data.buildMessage(Data.HMI_CONTROL_MSG, Data.HRCONTROL_OFF_MSG));
    }


    public void setTargetHeartRate(int targetHeartRate) {
        this.targetHeartRate = targetHeartRate;
    }
}
