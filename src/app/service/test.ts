import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class Test {

  constructor(private http: HttpClient) { }


  getData(): Observable<string> {
    return this.http.get('/api/', { 
      responseType: 'text',
      headers: new HttpHeaders({
        'Accept': 'text/plain'
      })
    });
  }


  uploadFile(data: FormData) {
    return this.http.post('/api/upload', data);
  }
}
