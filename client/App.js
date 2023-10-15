import { StatusBar } from 'expo-status-bar';
import { StyleSheet } from 'react-native';
import { useState } from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import MainScreen from './components/MainScreen';

export default function App() {
    /*
    Data to be stored:
    - current CO Concentration
    - History of CO Concentration (measured once each second/minute)
    - should have the ability to store the CO concentration on the app for even after it is closed (so that in case of emergency, ems can see on the phone, the level of CO exposure) (EXTRA)
    - could also store location data (EXTRA)
    */
    const [COConcentration, setCOConcentration] = useState(NaN);
    return (
        <SafeAreaProvider>
            <MainScreen COConcentration={COConcentration} />
        </SafeAreaProvider>
    );
}