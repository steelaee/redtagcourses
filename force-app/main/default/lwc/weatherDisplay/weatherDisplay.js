import { LightningElement, wire } from 'lwc';
import getAllWeatherRecords from '@salesforce/apex/WeatherController.getAllWeatherRecords';

export default class WeatherComponent extends LightningElement {
    weathers;

    connectedCallback(){
        this.loadWeathers();
    }

    loadWeathers(){
        getAllWeatherRecords()
            .then(result => {
                this.weathers = result;
            })
    }
}