# Deploy checklist

## GitHub repo
https://github.com/kidusp001-netizen/babes-notebook

## 1. Supabase database
In [Supabase SQL Editor](https://supabase.com/dashboard/project/fhiiunnbexmpajvkfuot/sql/new), run **in order**:
1. `supabase/migrations/001_journal_entries.sql`
2. `supabase/migrations/002_categories_multiple_entries.sql`

Then enable **Email** auth under Authentication → Providers.

## 2. GitHub secrets (Settings → Secrets → Actions)
| Secret | Value |
|--------|--------|
| `SUPABASE_URL` | `https://fhiiunnbexmpajvkfuot.supabase.co` ✅ already set |
| `SUPABASE_ANON_KEY` | From Supabase → Settings → API → **anon public** |

## 3. Push CI workflows
Your GitHub token needs the **`workflow`** scope. Create a new PAT at  
https://github.com/settings/tokens with **repo** + **workflow**, then:

```bash
cd "/Users/kidus/Documents/Projects/Babe's Notebook"
git add .github/workflows
git commit -m "Add GitHub Actions for web deploy and Android APK build"
git push origin main
```

## 4. Live web app
After workflows push and secrets are set, GitHub Actions deploys to:

**https://kidusp001-netizen.github.io/babes-notebook/**

## 5. Android APK
In GitHub → Actions → **Build Android APK** → Run workflow, or tag `v1.0.0`.

---

⚠️ **Revoke the token you pasted in chat** and create a new one — it was exposed.
