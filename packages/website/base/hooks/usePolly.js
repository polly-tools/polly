import useContract from "./useContract";
import pollyABI from '@polly-tools/core/abi/Polly.json';

export function usePolly(){
    return useContract({
        address: process.env.NEXT_PUBLIC_POLLY_ADDRESS,
        abi: pollyABI,
        endpoint: '/api/polly'
    });
}
