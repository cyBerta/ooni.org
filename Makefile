OONI_PROBE_REPO_DIR=../ooni-probe
-include make.conf

update-site:
	@echo "Updating the website on ooni.torproject.org from openobservatory.github.io"
	scp '-oProxyCommand=ssh perdulce.torproject.org -W %h:%p' update-site.sh staticiforme.torproject.org:
	ssh '-oProxyCommand=ssh perdulce.torproject.org -W %h:%p' -t staticiforme.torproject.org sudo -u ooni sh ./update-site.sh
	@echo "The website is now live at https://ooni.torproject.org/"

# NB: `make publish` is slow as it downloads whole website and re-uploads it back,
# you should not use it in your daily life, it's a disaster recovery procedure.
publish:
	rm -rf public
	hugo --theme=ooni --buildDrafts --baseUrl=https://ooni.torproject.org
	make -C ${OONI_PROBE_REPO_DIR}/docs clean
	make -C ${OONI_PROBE_REPO_DIR}/docs html
	cp -R ${OONI_PROBE_REPO_DIR}/docs/build/html/ public/docs/
	touch public/.nojekyll
	cd public && git init && git remote add pages git@github.com:OpenObservatory/openobservatory.github.io.git
	cd public && git add . && git commit -m 'Manual publishing'
	cd public && git push --force pages master
	@echo "You can now view the website at: https://openobservatory.github.io/"

server:
	hugo server --theme=ooni --baseUrl=http://127.0.0.1:1313 --buildDrafts
