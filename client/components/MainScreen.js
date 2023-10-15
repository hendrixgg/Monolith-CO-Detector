import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View, Button } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

/**
 * This component must be nested under a `SafeAreaProvider` element.
 * 
 * 
 * @param {{COConcentration: number}} props 
 * @returns {React.JSX.Element} View of the main screen of the app.
 */
export default function MainScreen({ COConcentration }) {
    return (
        <SafeAreaView style={styles.container}>
            <View style={{ justifyContent: 'center', width: '100%' }}>
                <View style={{ alignItems: 'center', width: '100%' }}>
                    <Text>MONOLITH (use good font/logo)</Text>
                </View>
                {/* 
                Have not decided yet what the menu (settings for accounts and notifications) will contain.
                Overall Requirements (users should be able to specify):
                - notifications
                - what is stored for the session
                    - location
                    - time
                    - session name
                - manage stored data
                    - previous sessions
                 */}
                <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-evenly' }}>
                    <Button style={styles.menuItem} title="settings" /><Button style={styles.menuItem} title="account" />
                </View>
            </View>
            <View style={{ alignItems: 'center' }}>
                <Text>CO Concentration</Text>
                <Text>{isNaN(COConcentration) ? '-' : COConcentration} ppm</Text>
                {/*
                View below should be for the Graph of CO Concentration over time.
                Requirements:
                - title
                - CO Concentration (ppm) on vertical axis
                - Time on horizontal axis
                - Highlighted Range of "safe" CO levels
                - Highlighted Range of "dangerous" CO levels
                - resizeable horizontal axis
                - scrollable horizontal axis
                EXTRA:
                - option to select graph for current session or for previous saved sessions
                    - this selection should be a searchable menu that allows you to search by date or by location or by session name
                */}
                <View style={{ alignItems: 'center' }}>
                    <Text>Insert Graph Here</Text>
                </View>
            </View>
            <View style={styles.footer}>
                <Text>Insert Ad Here</Text>
            </View>
            <StatusBar style="auto" />
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#fff',
        alignItems: 'center',
        justifyContent: 'space-between',
        padding: 10
    },
    menuItem: {
    }
});
