export default function getBaseUrl(){

    switch(process.env.NETWORK_ID){
        case '1':
            return 'https://polly.tools';
        case '5':
            return 'https://testnet.polly.tools';
        case '31337':
            return 'http://localhost:3000';
        default:
            return 'https://polly.tools';
    }

}