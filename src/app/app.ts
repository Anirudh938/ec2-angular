import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { Test } from './service/test';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, CommonModule],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {
  
  protected title = 'ec2-angular';
  selectedFile: File | null = null;
  isUploading: boolean = false;

  constructor(private testService: Test) {
  }

  getData(){
    this.testService.getData().subscribe((data) => {
      console.log(data);
    });
  }


  onFileSelected(event: any): void {
    this.selectedFile = event.target.files[0];
  }
  
  uploadFile(): void {
    if (!this.selectedFile) {
      return;
    }
    
    this.isUploading = true;
    
    const formData = new FormData();
    formData.append('file', this.selectedFile, this.selectedFile.name);
    this.testService.uploadFile(formData).subscribe(() => {
      this.isUploading = false;
      this.selectedFile = null; 
      console.log('File uploaded successfully');
    });
  }

  getValue(value: string) {
    this.testService.getDetails(value).subscribe((data) => {
      console.log(data);
    });
  }
}
