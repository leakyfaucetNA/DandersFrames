# Switch to main and pull the author's latest
git checkout main
git fetch upstream
git merge upstream/main
git push origin main

# Now bring those updates into your branch
git checkout my-changes
git rebase main
