.DEFAULT_GOAL := help

.PHONY: help dev dev-web dev-web-app build-client build-web build-vercel deploy-web deploy-supabase setup-env ci

SUPABASE_URL := https://cgxzpdhcaxiopdylwstr.supabase.co
SUPABASE_ANON_KEY := eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNneHpwZGhjYXhpb3BkeWx3c3RyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg5NDIzNzksImV4cCI6MjA5NDUxODM3OX0.lNOk6lL3CmMFh8gXoA6hrnW1QcWxpaz2sTTKVOY83fg

help: ## List available commands
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

dev: ## Run Flutter mobile app (client/)
	cd client && flutter run \
		--dart-define=SUPABASE_URL=$(SUPABASE_URL) \
		--dart-define=SUPABASE_ANON_KEY=$(SUPABASE_ANON_KEY)

dev-web-app: ## Start Next.js (landing + admin) on port 3000
	cd web && npm run dev

dev-web: ## Build Flutter web and serve locally
	bash scripts/build-web.sh
	bash scripts/serve-static-web.sh

build-client: ## Build Flutter APK (client/)
	cd client && flutter build apk --release \
		--dart-define=SUPABASE_URL=$(SUPABASE_URL) \
		--dart-define=SUPABASE_ANON_KEY=$(SUPABASE_ANON_KEY)

build-web: ## Build Flutter web release (client/build/web)
	bash scripts/build-web.sh

build-vercel: ## Build Flutter web + Next.js for Vercel
	bash scripts/build-vercel.sh

deploy-web: ## Deploy web to Vercel production
	cd web && vercel --prod

deploy-supabase: ## Deploy migrations and Edge Functions to Supabase
	bash scripts/deploy-supabase.sh cgxzpdhcaxiopdylwstr

seed-cloud: ## Hosted demo data (run supabase/seed-cloud.sql in SQL Editor if empty)
	@echo "Cloud seed applied via Dashboard. Re-run: supabase/seed-cloud.sql on project cgxzpdhcaxiopdylwstr"

setup-env: ## Copy .env.example → .env.local for web
	cp web/.env.example web/.env.local

ci: ## Run Flutter analyze/tests + web lint
	cd client && flutter pub get && flutter analyze && flutter test
	cd web && npm ci && npm run lint
