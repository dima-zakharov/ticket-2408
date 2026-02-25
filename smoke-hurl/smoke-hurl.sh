source 00-env.sh

hurl --test \
	--variable base_url=$BASE_URL \
	--variable token=$TOKEN \
	--report-html reports \
	smoke-test.hurl
