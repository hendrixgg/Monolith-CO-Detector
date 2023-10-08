import { useState } from 'react';
import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View } from 'react-native';

export default function App() {
    const [coConcentration, setCoConcentration] = useState(15);
    return (
        <View style={styles.container}>
            <StatusBar style="auto" />
            <Text>MONOLITH</Text>
            <Text>CO Concentration</Text>
            <Text>{coConcentration} ppm</Text>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#fff',
        alignItems: 'center',
        justifyContent: 'center',
    },
});
