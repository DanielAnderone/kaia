// App.tsx
import 'react-native-gesture-handler';
import React from 'react';
import { Platform, View, Text } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';

// telas
import LoginView from './src/view/login.view';
import SignUpView from './src/view/signup.view';
import ProjectsView from './src/view/client/project.view';
import PaymentView from './src/view/client/payment.view';
import TransactionsView from './src/view/client/transactions.view';
import AccountView from './src/view/client/profile.view';
import InvestmentsView from './src/view/client/investiment.view';
import AdminDashboardView from './src/view/admin/admin.dasbord';
import AdminProfileScreen from './src/view/admin/admin.profile';
import AdminProjectManagementView from './src/view/admin/admin.project.management';
import AdminSettingsView from './src/view/admin/admin.settings';
import InvestmentManagementView from './src/view/admin/admin.investiment.management';
import InvestorsView from './src/view/client/investors.view';

const Forgot = () => (
  <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
    <Text>Recuperar senha (em breve)</Text>
  </View>
);

export type RootStackParamList = {
  Login: undefined;
  SignUp: { apiBaseUrl?: string; buttonColor?: string } | undefined;
  InvestorProjects: undefined;
  InvestorPayments: undefined;
  InvestorTransactions: undefined;
  InvestorProfile: undefined;
  InvestorInvestments: undefined;
  AdminInvestments: undefined;
  AdminDashboard: undefined;
  AdminProjectManagement: undefined;
  AdminInvestors: undefined;
  AdminProfile: undefined;
  AdminSettings: undefined;
  Forgot: undefined;
};

const Stack = createStackNavigator<RootStackParamList>();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Login" screenOptions={{ headerShown: false }}>
        <Stack.Screen name="Login" component={LoginView} />
        <Stack.Screen name="SignUp" component={SignUpView} />
        <Stack.Screen name="InvestorProjects" component={ProjectsView} />
        <Stack.Screen name="InvestorPayments" component={PaymentView} />
        <Stack.Screen name="InvestorTransactions" component={TransactionsView} />
        <Stack.Screen name="InvestorProfile" component={AccountView} />
        <Stack.Screen name="InvestorInvestments" component={InvestmentsView} />
        <Stack.Screen name="AdminInvestments" component={InvestmentManagementView} />
        <Stack.Screen name="AdminDashboard" component={AdminDashboardView} />
        <Stack.Screen name="AdminProjectManagement" component={AdminProjectManagementView} />
        <Stack.Screen name="AdminInvestors" component={InvestorsView} />
        <Stack.Screen name="AdminProfile" component={AdminProfileScreen} />
        <Stack.Screen name="AdminSettings" component={AdminSettingsView} />
        <Stack.Screen name="Forgot" component={Forgot} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
