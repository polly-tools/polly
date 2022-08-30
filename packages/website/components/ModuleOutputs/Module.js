import ModuleInterface, { ModuleInterfaceProvider } from "components/ModuleInterface/ModuleInterface";
import Modal, { ModalInner, ModalActions } from "components/Modal";
import { useState } from "react";
import Button from "components/Button";

export default function Module({info, param, ...p}){

    const [openModule, setOpenModule] = useState(false);

    return <div>
        
            <a href="#" onClick={() => setOpenModule(true)}>Settings</a>
                
            <Modal show={openModule}>
                <ModalInner>

                <ModuleInterfaceProvider name={info.name}>
                    <h3>{info.name}</h3>
                    <ModuleInterface info={info} address={param._address}/>
                </ModuleInterfaceProvider>

                <ModalActions actions={[{label: 'Close', callback: () => setOpenModule(false)}]}/>

                </ModalInner>
            </Modal>

        </div>
}