# Firefox Policies

/!\ DO NOT STOW THIS PACKAGE /!\

Stowing this package does not have any effect. To setup Firefox policies, refer to the instructions below.

## About Firefox Policies

> Policies (also called "enterprise policies" or "group policies") can be used to apply browser configuration to Firefox.
>
> Source: [_Firefox administrator reference_](https://firefox-admin-docs.mozilla.org/reference/)

Normally, Firefox policies are meant for enterprise use cases. However, as a standard user, it possible to apply them to statically configure parts of Firefox's behaviour.

## How to install the policies

As of the time of writing this README file, Firefox only looks for a `policies.json` file at `/etc/firefox/policies/`. Given the restrictions in the `/etc` directory, the easiest method to install and modify the policy file is to create a symlink between the `policies.json` file in this folder and the expected address by Firefox.

It possible to create a symlink like this (supposing you are `cd`-ed into the folder containing this `README`):

```sh
ln -s policies.json /etc/firefox/policies/policies.json
```

## Policies description

| Policy | Description | Value |
|-|-|-|
| **AppAutoUpdate** | Enable or disable automatic application update. | `false` |
| **AutofillAddressEnabled** | Enables or disables autofill for addresses. | `false` |
| **AutofillCreditCardEnabled** | Enables or disables autofill for payment methods.| `false` |
| **DisableAppUpdate** | Turn off application updates within Firefox. | `true` |
| **DisableFormHistory** | Turn off saving information on web forms and the search bar. | `true` |
| **DisableProfileImport** | Remove the ability to import data from other browsers. | `true` |
| **DNSOverHTTPS** | Configure DNS over HTTPS. | `{ "Enabled": true, "ProviderURL": "https://adblock.dns.mullvad.net/dns-query", "Locked": true, "Fallback": true }` |
| **DontCheckDefaultBrowser** | Don't check if Firefox is the default browser at startup. | `true` |
| **GenerativeAI** | Configure generative AI features. | `{ "Enabled": false, "Locked": true }` |
| **Homepage** | Configure the default homepage and how Firefox starts. | `{ "StartPage": "previous-session" }` |
| **HttpsOnlyMode** | Configure HTTPS-Only Mode. | `"force_enabled"` |
| **OfferToSaveLoginsDefault** | Sets the default value of `signon.rememberSignons` without locking it. | `false` |
| **PasswordManagerEnabled** | Remove access to the password manager via preferences and blocks about:logins on Firefox 70. | `false` |
| **SanitizeOnShutdown** | Clear local data on shutdown. | `{ "Cache": true, "Cookies": false, "FormData": true, "History": false, "Sessions": false, "SiteSettings": false, "Locked": false }` |
| **SearchEngines** | Configure search engines in Firefox. | `...` |
| **ShowHomeButton** | Show the home button on the toolbar. | `false` |
