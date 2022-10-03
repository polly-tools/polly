import useModule from "base/hooks/useModule";
import ModuleInterface, { ModuleInterfaceProvider, useModuleInterface } from "components/ModuleInterface";
import Page from "templates/Page";
import { useRouter } from "next/router";
import { useEffect, useState} from "react";



function ModuleScreen(p){

  const {fetching, address, module} = useModuleInterface();

  return <div>
    {module && <>
      <small>{address}</small>
      <h1>{module.name} <small>v{module.version}</small></h1>
      <ModuleInterface/>
      </>
    }
  </div>

}


export default function Module({p}){

  const router = useRouter();
  const {address} = router.query;
  return <Page header>
    {address && <ModuleInterfaceProvider address={address}>
      <ModuleScreen/>
    </ModuleInterfaceProvider>
    }
  </Page>

}
