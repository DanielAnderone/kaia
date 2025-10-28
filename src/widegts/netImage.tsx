// src/widgets/NetImage.tsx
import React, { useState } from 'react';
import { View, Image, ActivityIndicator, StyleSheet, Text, ImageResizeMode, StyleProp, ViewStyle } from 'react-native';

type Fit = Extract<ImageResizeMode, 'cover' | 'contain' | 'stretch' | 'center'>;

type Props = {
  url: string;
  fit?: Fit;          // default: 'cover'
  width?: number;
  height?: number;
  style?: StyleProp<ViewStyle>;
};

const GRAY_BG = '#E5E7EB';
const GRAY_ICON = '#6B7280';

const NetImage: React.FC<Props> = ({ url, fit = 'cover', width, height, style }) => {
  const [loading, setLoading] = useState<boolean>(true);
  const [failed, setFailed] = useState<boolean>(false);

  const boxStyle: StyleProp<ViewStyle> = [
    styles.box,
    { width, height, backgroundColor: GRAY_BG },
    style,
  ];

  if (failed) {
    return (
      <View style={boxStyle}>
        <Text style={[styles.errIcon, { color: GRAY_ICON }]}>🖼️</Text>
      </View>
    );
  }

  return (
    <View style={boxStyle}>
      <Image
        source={{ uri: url }}
        resizeMode={fit}
        style={StyleSheet.absoluteFill}
        onLoadStart={() => setLoading(true)}
        onLoadEnd={() => setLoading(false)}
        onError={() => {
          setLoading(false);
          setFailed(true);
        }}
      />
      {loading && (
        <View style={styles.loaderWrap}>
          <ActivityIndicator size="small" color="#000" />
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  box: {
    overflow: 'hidden',
    justifyContent: 'center',
    alignItems: 'center',
  },
  loaderWrap: {
    width: 20,
    height: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  errIcon: {
    fontSize: 32,
  },
});

export default NetImage;
