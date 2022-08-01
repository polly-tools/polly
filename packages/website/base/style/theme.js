const mainColor = '#0328CE';

export const colors = {
    main: mainColor,
    main_dimmed: '#777',
    white: '#fff',
    bg: '#ffffff',
    altBg: '#cfcfcf',
    text: mainColor,
};



const theme = {
    fonts: [
        {
            family: "'Inter', sans-serif;",
            regular: 400,
            bold: 500,
            letterSpacing: '0.1 em'
        }
    ],
    colors: colors,
    breakpoints: {
      sm: 1,
      md: 768,
      lg: 992
    }
}

export default theme;