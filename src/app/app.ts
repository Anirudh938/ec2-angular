import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { Test } from './service/test';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {
  protected title = 'ec2-angular';

  constructor(private testService: Test) {
    this.getData();
  }

  getData(){
    this.testService.getData().subscribe((data) => {
      console.log(data);
    });
  }
}
