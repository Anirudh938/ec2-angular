import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class Test {

  constructor(private http: HttpClient) { }


  getData(): Observable<string> {
    return this.http.get('http://localhost:8080/api/', { 
      responseType: 'text',
      headers: new HttpHeaders({
        'Accept': 'text/plain'
      })
    });
  }


  uploadFile(data: FormData) {
    return this.http.post('http://localhost:8080/api/upload', data);
  }

  getDetails(id: string): Observable<string> {
    return this.http.get('http://localhost:8080/api/' + id, { 
      responseType: 'text',
      headers: new HttpHeaders({
        'Accept': 'text/plain'
      })
    });
  }  
}
