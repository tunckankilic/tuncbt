const fs = require('fs');
const path = require('path');

class I18n {
    constructor() {
        this.translations = {};
        this.defaultLocale = 'tr';
        this.supportedLocales = ['tr', 'en', 'de'];
        this.loadTranslations();
    }

    loadTranslations() {
        const localesDir = path.join(__dirname, 'locales');
        fs.readdirSync(localesDir).forEach(file => {
            const locale = path.parse(file).name;
            const filePath = path.join(localesDir, file);
            this.translations[locale] = JSON.parse(fs.readFileSync(filePath, 'utf8'));
        });
    }

    isLocaleSupported(locale) {
        return this.supportedLocales.includes(locale);
    }

    getFallbackLocale(locale) {
        // Eğer desteklenmeyen bir dil ise veya dil belirtilmemişse
        if (!locale || !this.isLocaleSupported(locale)) {
            return this.defaultLocale;
        }
        return locale;
    }

    t(key, locale = this.defaultLocale) {
        try {
            const targetLocale = this.getFallbackLocale(locale);
            const parts = key.split('.');
            let translation = this.translations[targetLocale];
            
            for (const part of parts) {
                if (!translation || !translation[part]) {
                    // Eğer çeviri bulunamazsa, sırasıyla şu dillere bakılır:
                    // 1. İngilizce (en)
                    // 2. Varsayılan dil (tr)
                    const fallbackLocales = ['en', this.defaultLocale];
                    
                    for (const fallbackLocale of fallbackLocales) {
                        if (fallbackLocale === targetLocale) continue;
                        
                        let fallbackTranslation = this.translations[fallbackLocale];
                        let found = true;
                        
                        for (const p of parts) {
                            if (!fallbackTranslation || !fallbackTranslation[p]) {
                                found = false;
                                break;
                            }
                            fallbackTranslation = fallbackTranslation[p];
                        }
                        
                        if (found) {
                            return fallbackTranslation;
                        }
                    }
                    
                    // Hiçbir dilde çeviri bulunamazsa anahtarı döndür
                    return key;
                }
                translation = translation[part];
            }

            return translation || key;
        } catch (error) {
            console.error(`Translation error for key: ${key}, locale: ${locale}`, error);
            return key;
        }
    }

    /**
     * Belirli bir dil için tüm çevirileri döndürür
     * @param {string} locale - Dil kodu
     * @returns {Object} Çeviri objesi
     */
    getAllTranslations(locale) {
        const targetLocale = this.getFallbackLocale(locale);
        return this.translations[targetLocale] || {};
    }

    /**
     * Eksik çevirileri kontrol eder
     * @returns {Object} Eksik çeviriler
     */
    checkMissingTranslations() {
        const missing = {};
        const referenceTranslations = this.getAllTranslations(this.defaultLocale);
        
        this.supportedLocales.forEach(locale => {
            if (locale === this.defaultLocale) return;
            
            missing[locale] = [];
            const translations = this.getAllTranslations(locale);
            
            const checkRecursive = (ref, trans, path = '') => {
                Object.keys(ref).forEach(key => {
                    const currentPath = path ? `${path}.${key}` : key;
                    
                    if (typeof ref[key] === 'object') {
                        if (!trans[key]) {
                            missing[locale].push(currentPath);
                        } else {
                            checkRecursive(ref[key], trans[key], currentPath);
                        }
                    } else if (!trans[key]) {
                        missing[locale].push(currentPath);
                    }
                });
            };
            
            checkRecursive(referenceTranslations, translations);
        });
        
        return missing;
    }
}

module.exports = new I18n(); 