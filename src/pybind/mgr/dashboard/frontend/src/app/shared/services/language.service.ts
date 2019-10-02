import { HttpClient } from '@angular/common/http';
import { Inject, LOCALE_ID } from '@angular/core';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class LanguageService {
  constructor(private http: HttpClient, @Inject(LOCALE_ID) protected localeId: string) {}

  getLocale(): string {
    return this.localeId || 'en-US';
  }

  setLocale(lang: string) {
    document.cookie = `cd-lang=${lang}`;
  }

  getLanguages() {
    return this.http.get<string[]>('ui-api/langs');
  }
}
